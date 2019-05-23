# ------------------------------------------------------------------------------
# CREATE A CLIENT CERTIFICATE FOR CLOUD SQL DATABASE
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# CONFIGURE OUR GCP CONNECTION
# ------------------------------------------------------------------------------

provider "google-beta" {
  version = "~> 2.7.0"
  region  = "${var.region}"
  project = "${var.project}"
}

# Use Terraform 0.10.x so that we can take advantage of Terraform GCP functionality as a separate provider via
# https://github.com/terraform-providers/terraform-provider-google
terraform {
  required_version = ">= 0.10.3"
}

# ------------------------------------------------------------------------------
# CREATE CLIENT CERTIFICATE
# ------------------------------------------------------------------------------

resource "google_sql_ssl_cert" "client_cert" {
  provider    = "google-beta"
  common_name = "${var.common_name}"
  instance    = "${var.database_instance_name}"
}
