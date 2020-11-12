# ------------------------------------------------------------------------------
# CREATE A CLIENT CERTIFICATE FOR CLOUD SQL DATABASE
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# CONFIGURE OUR GCP CONNECTION
# ------------------------------------------------------------------------------

provider "google-beta" {
  version = "~> 3.43.0"
  project = var.project
  region  = var.region
}

terraform {
  # This module is now only being tested with Terraform 0.13.x. However, to make upgrading easier, we are setting
  # 0.12.26 as the minimum version, as that version added support for required_providers with source URLs, making it
  # forwards compatible with 0.13.x code.
  required_version = ">= 0.12.26"
}

# ------------------------------------------------------------------------------
# CREATE CLIENT CERTIFICATE
# ------------------------------------------------------------------------------

resource "google_sql_ssl_cert" "client_cert" {
  provider    = google-beta
  common_name = var.common_name
  instance    = var.database_instance_name
}
