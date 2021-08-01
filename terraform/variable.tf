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
