variable "project" {
  description = "A name of a GCP Project"
  type        = string
  default     = null
}

variable "region" {
  description = "A region to use the module"
  type        = string
  default     = "us-east1"
}

variable "zone" {
  description = "A zone to use the module"
  type        = string
  default     = "us-east1-a"
}

variable "lb_name" {
  description = "Load balancer name"
  type        = string
  default     = "streamlit"
}

variable "lb-domain" {
  description = "Load balancer domain"
  type        = string
  default     = "example.com"
}

variable "iapHttpsResourceAccessor" {
  description = "roles/iap.httpsResourceAccessor"
  type        = string
  default     = "tosh2230@example.com"
}

variable "iap_client_id" {
  description = "iap_client_id"
  type        = string
  default     = null
}

variable "iap_client_secret" {
  description = "iap_client_secret"
  type        = string
  default     = null
  sensitive   = true
}
