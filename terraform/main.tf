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

# resource "google_project_iam_binding" "streamlit_run_bq_user" {
#   project = var.project
#   role    = "roles/bigquery.user"
#   members = ["serviceAccount:${google_service_account.sa_streamlit_run.email}"]
# }

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
# Output
##############################################
output "streamlit_run_url" {
  value = google_cloud_run_service.streamlit_run.status[0].url
}
