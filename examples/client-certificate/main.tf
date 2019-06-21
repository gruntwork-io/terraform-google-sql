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

terraform {
  # The modules used in this example have been updated with 0.12 syntax, which means the example is no longer
  # compatible with any versions below 0.12.
  required_version = ">= 0.12"
}

# ------------------------------------------------------------------------------
# CREATE CLIENT CERTIFICATE
# ------------------------------------------------------------------------------

resource "google_sql_ssl_cert" "client_cert" {
  provider    = "google-beta"
  common_name = "${var.common_name}"
  instance    = "${var.database_instance_name}"
}
