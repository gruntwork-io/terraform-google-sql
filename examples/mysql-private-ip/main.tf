# ------------------------------------------------------------------------------
# LAUNCH A MYSQL CLOUD SQL PRIVATE IP INSTANCE
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
# CREATE A RANDOM SUFFIX AND PREPARE RESOURCE NAMES
# ------------------------------------------------------------------------------

resource "random_id" "name" {
  byte_length = 2
}

locals {
  # If name_override is specified, use that - otherwise use the name_prefix with a random string
  instance_name        = "${length(var.name_override) == 0 ? format("%s-%s", var.name_prefix, random_id.name.hex) : var.name_override}"
  private_network_name = "private-network-${random_id.name.hex}"
  private_ip_name      = "private-ip-${random_id.name.hex}"
}

# ------------------------------------------------------------------------------
# CREATE COMPUTE NETWORKS
# ------------------------------------------------------------------------------

# Simple network, auto-creates subnetworks
resource "google_compute_network" "private_network" {
  provider = "google-beta"
  name     = "${local.private_network_name}"
}

# Reserve global internal address range for the peering
resource "google_compute_global_address" "private_ip_address" {
  provider      = "google-beta"
  name          = "${local.private_ip_name}"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = "${google_compute_network.private_network.self_link}"
}

# Establish VPC network peering connection using the reserved address range
resource "google_service_networking_connection" "private_vpc_connection" {
  provider                = "google-beta"
  network                 = "${google_compute_network.private_network.self_link}"
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = ["${google_compute_global_address.private_ip_address.name}"]
}

# ------------------------------------------------------------------------------
# CREATE DATABASE INSTANCE WITH PRIVATE IP
# ------------------------------------------------------------------------------

module "mysql" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "github.com/gruntwork-io/terraform-google-sql.git//modules/cloud-sql?ref=v0.1.1"
  source = "../../modules/cloud-sql"

  project = "${var.project}"
  region  = "${var.region}"
  name    = "${local.instance_name}"
  db_name = "${var.db_name}"

  engine       = "${var.mysql_version}"
  machine_type = "${var.machine_type}"

  # These together will construct the master_user privileges, i.e.
  # 'master_user_name'@'master_user_host' IDENTIFIED BY 'master_user_password'.
  # These should typically be set as the environment variable TF_VAR_master_user_password, etc.
  # so you don't check these into source control."
  master_user_password = "${var.master_user_password}"

  master_user_name = "${var.master_user_name}"
  master_user_host = "%"

  # Pass the private network link to the module
  private_network = "${google_compute_network.private_network.self_link}"

  # Wait for the vpc connection to complete
  dependencies = ["${google_service_networking_connection.private_vpc_connection.network}"]

  # Set auto-increment flags to test the
  # feature during automated testing
  database_flags = [
    {
      name  = "auto_increment_increment"
      value = "6"
    },
    {
      name  = "auto_increment_offset"
      value = "6"
    },
  ]

  custom_labels = {
    test-id = "mysql-private-ip-example"
  }
}
