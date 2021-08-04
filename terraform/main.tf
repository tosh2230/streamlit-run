provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

terraform {
  backend "gcs" {
  }
}

##############################################
# Service Account
##############################################
resource "google_service_account" "sa_streamlit_run" {
  account_id   = "sa-streamlit-run"
  display_name = "sa-streamlit-run"
}

resource "google_project_iam_binding" "streamlit_run_bq_user" {
  project = var.project
  role    = "roles/bigquery.user"
  members = ["serviceAccount:${google_service_account.sa_streamlit_run.email}"]
}

##############################################
# Cloud Run
##############################################
resource "google_cloud_run_service" "streamlit_run" {
  name     = "streamlit-run"
  location = var.region
  template {
    spec {
      containers {
        image = "gcr.io/${var.project}/streamlit_run"
        resources {
          limits = {
            "cpu" : "1000m"
            "memory" : "256Mi"
          }
        }
      }
      service_account_name = google_service_account.sa_streamlit_run.email
    }
  }
  metadata {
    annotations = {
      "run.googleapis.com/ingress" = "internal-and-cloud-load-balancing"
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
}

##############################################
# Cloud Load Balancing
##############################################
resource "google_compute_global_address" "address" {
  name = "${var.lb_name}-address"
}

resource "google_compute_managed_ssl_certificate" "cert" {
  name = "${var.lb_name}-cert"
  managed {
    domains = ["${var.lb-domain}"]
  }
}

resource "google_compute_region_network_endpoint_group" "neg" {
  name                  = "${var.lb_name}-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = google_cloud_run_service.streamlit_run.name
  }
}

resource "google_compute_backend_service" "backend" {
  name        = "${var.lb_name}-backend"
  protocol    = "HTTPS"
  port_name   = "http"
  timeout_sec = 30
  backend {
    group = google_compute_region_network_endpoint_group.neg.id
  }
  iap {
    oauth2_client_id     = var.iap_client_id
    oauth2_client_secret = var.iap_client_secret
  }
}

resource "google_iap_web_backend_service_iam_binding" "binding" {
  project             = google_compute_backend_service.backend.project
  web_backend_service = google_compute_backend_service.backend.name
  role                = "roles/iap.httpsResourceAccessor"
  members = [
    "user:${var.iapHttpsResourceAccessor}",
  ]
}

resource "google_compute_url_map" "urlmap" {
  name            = "${var.lb_name}-urlmap"
  default_service = google_compute_backend_service.backend.id
  host_rule {
    hosts        = ["${var.lb-domain}"]
    path_matcher = "mysite"
  }
  path_matcher {
    name            = "mysite"
    default_service = google_compute_backend_service.backend.id

    path_rule {
      paths   = ["/sample1"]
      service = google_compute_backend_service.backend.id
    }
    path_rule {
      paths   = ["/sample2"]
      service = google_compute_backend_service.backend.id
    }
  }
}

resource "google_compute_target_https_proxy" "https_proxy" {
  name    = "${var.lb_name}-https-proxy"
  url_map = google_compute_url_map.urlmap.id
  ssl_certificates = [
    google_compute_managed_ssl_certificate.cert.id
  ]
}

resource "google_compute_global_forwarding_rule" "lb" {
  name       = "${var.lb_name}-lb"
  target     = google_compute_target_https_proxy.https_proxy.id
  port_range = "443"
  ip_address = google_compute_global_address.address.address
}

##############################################
# Output
##############################################
output "streamlit_run_url" {
  value = google_cloud_run_service.streamlit_run.status[0].url
}

output "load_balancer_ip" {
  value = google_compute_global_address.address.address
}
