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
resource "google_cloud_run_service" "streamlit_run_default" {
  name     = "streamlit-run-default"
  location = var.region
  template {
    spec {
      containers {
        image = "gcr.io/${var.project}/streamlit_run_default:latest"
        resources {
          limits = {
            "cpu" : "1000m"
            "memory" : "512Mi"
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

resource "google_cloud_run_service" "streamlit_run_backend01" {
  name     = "streamlit-run-backend01"
  location = var.region
  template {
    spec {
      containers {
        image = "gcr.io/${var.project}/streamlit_run_backend01:latest"
        resources {
          limits = {
            "cpu" : "1000m"
            "memory" : "512Mi"
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

resource "google_cloud_run_service" "streamlit_run_backend02" {
  name     = "streamlit-run-backend02"
  location = var.region
  template {
    spec {
      containers {
        image = "gcr.io/${var.project}/streamlit_run_backend02:latest"
        resources {
          limits = {
            "cpu" : "1000m"
            "memory" : "512Mi"
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

resource "google_compute_url_map" "urlmap" {
  name            = "${var.lb_name}-lb"
  default_service = google_compute_backend_service.backend_default.id
}

resource "google_compute_target_https_proxy" "https_proxy" {
  name    = "${var.lb_name}-https-proxy"
  url_map = google_compute_url_map.urlmap.id
  ssl_certificates = [
    google_compute_managed_ssl_certificate.cert.id
  ]
}

resource "google_compute_global_forwarding_rule" "rule" {
  name       = "${var.lb_name}-rule"
  target     = google_compute_target_https_proxy.https_proxy.id
  port_range = "443"
  ip_address = google_compute_global_address.address.address
}

# Backend default
resource "google_compute_region_network_endpoint_group" "neg_default" {
  name                  = "${var.lb_name}-neg-default"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    url_mask = "${var.lb-domain}/<service>"
  }
}

resource "google_compute_backend_service" "backend_default" {
  name        = "${var.lb_name}-backend-default"
  protocol    = "HTTPS"
  port_name   = "http"
  timeout_sec = 30
  backend {
    group = google_compute_region_network_endpoint_group.neg_default.id
  }
  iap {
    oauth2_client_id     = var.iap_client_id
    oauth2_client_secret = var.iap_client_secret
  }
  log_config {
    enable = true
  }
}

resource "google_iap_web_backend_service_iam_binding" "binding_default" {
  project             = google_compute_backend_service.backend_default.project
  web_backend_service = google_compute_backend_service.backend_default.name
  role                = "roles/iap.httpsResourceAccessor"
  members = [
    "user:${var.iapHttpsResourceAccessor}",
  ]
}

##############################################
# Output
##############################################
output "load_balancer_ip" {
  value = google_compute_global_address.address.address
}
