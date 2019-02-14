# ------------------------------------------------------------------------------
# LAUNCH A POSTGRES CLUSTER WITH HA AND READ REPLICAS
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# CONFIGURE OUR GCP CONNECTION
# ------------------------------------------------------------------------------

provider "google-beta" {
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
# CREATE DATABASE CLUSTER WITH PUBLIC IP
# ------------------------------------------------------------------------------

module "postgres" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "git::git@github.com:gruntwork-io/terraform-google-sql.git//modules/cloud-sql?ref=v0.1.0"
  source = "../../modules/cloud-sql"

  project = "${var.project}"
  region  = "${var.region}"
  name    = "${local.instance_name}"
  db_name = "${var.db_name}"

  engine       = "${var.postgres_version}"
  machine_type = "${var.machine_type}"

  master_zone = "${var.master_zone}"

  # To make it easier to test this example, we are giving the servers public IP addresses and allowing inbound
  # connections from anywhere. In real-world usage, your servers should live in private subnets, only have private IP
  # addresses, and only allow access from specific trusted networks, servers or applications in your VPC.
  enable_public_internet_access = true

  authorized_networks = [
    {
      name  = "allow-all-inbound"
      value = "0.0.0.0/0"
    },
  ]

  # Indicate that we want to create a failover replica
  enable_failover_replica = true

  # Indicate we want read replicas to be created
  num_read_replicas  = "${var.num_read_replicas}"
  read_replica_zones = ["${var.read_replica_zones}"]

  # These together will construct the master_user privileges, i.e.
  # 'master_user_name'@'master_user_host' IDENTIFIED BY 'master_user_password'.
  # These should typically be set as the environment variable TF_VAR_master_user_password, etc.
  # so you don't check these into source control."
  master_user_password = "${var.master_user_password}"

  master_user_name = "${var.master_user_name}"
  master_user_host = "%"

  custom_labels = {
    test-id = "postgres-replicas-example"
  }
}
