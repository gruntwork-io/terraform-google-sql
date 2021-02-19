# ------------------------------------------------------------------------------
# LAUNCH A POSTGRES CLUSTER WITH HA AND READ REPLICAS
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# CONFIGURE OUR GCP CONNECTION
# ------------------------------------------------------------------------------

provider "google-beta" {
  version = "~> 3.57.0"
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
# CREATE A RANDOM SUFFIX AND PREPARE RESOURCE NAMES
# ------------------------------------------------------------------------------

resource "random_id" "name" {
  byte_length = 2
}

locals {
  # If name_override is specified, use that - otherwise use the name_prefix with a random string
  instance_name        = var.name_override == null ? format("%s-%s", var.name_prefix, random_id.name.hex) : var.name_override
  private_network_name = "private-network-${random_id.name.hex}"
  private_ip_name      = "private-ip-${random_id.name.hex}"
}

# ------------------------------------------------------------------------------
# CREATE DATABASE CLUSTER WITH PUBLIC IP
# ------------------------------------------------------------------------------

module "postgres" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "github.com/gruntwork-io/terraform-google-sql.git//modules/cloud-sql?ref=v0.2.0"
  source = "../../modules/cloud-sql"

  project = var.project
  region  = var.region
  name    = local.instance_name
  db_name = var.db_name

  engine       = var.postgres_version
  machine_type = var.machine_type

  master_zone = var.master_zone

  # To make it easier to test this example, we are giving the instances public IP addresses and allowing inbound
  # connections from anywhere. We also disable deletion protection so we can destroy the databases during the tests.
  # In real-world usage, your instances should live in private subnets, only have private IP addresses, and only allow
  # access from specific trusted networks, servers or applications in your VPC. By default, we recommend setting
  # deletion_protection to true, to ensure database instances are not inadvertently destroyed.
  enable_public_internet_access = true
  deletion_protection           = false

  authorized_networks = [
    {
      name  = "allow-all-inbound"
      value = "0.0.0.0/0"
    },
  ]

  # Indicate that we want to create a failover replica
  enable_failover_replica = true

  # Indicate we want read replicas to be created
  num_read_replicas  = var.num_read_replicas
  read_replica_zones = var.read_replica_zones

  # These together will construct the master_user privileges, i.e.
  # 'master_user_name' IDENTIFIED BY 'master_user_password'.
  # These should typically be set as the environment variable TF_VAR_master_user_password, etc.
  # so you don't check these into source control."
  master_user_password = var.master_user_password
  master_user_name     = var.master_user_name

  custom_labels = {
    test-id = "postgres-replicas-example"
  }
}
