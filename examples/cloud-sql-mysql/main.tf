provider "google-beta" {
  region = "${var.region}"
  project = "${var.project}"
}

# Use Terraform 0.10.x so that we can take advantage of Terraform GCP functionality as a separate provider via
# https://github.com/terraform-providers/terraform-provider-google
terraform {
  required_version = ">= 0.10.3"
}

resource "random_id" "name" {
  byte_length = 2
}

locals {
  # If name_override is specified, use that - otherwise use the name_prefix with a random string
  instance_name = "${length(var.name_override) == 0 ? format("%s-%s", var.name_prefix, random_id.name.hex) : var.name_override}"
}

module "mysql" {
  source                          = "../../modules/mysql"

  project                         = "${var.project}"
  region                          = "${var.region}"
  name                            = "${local.instance_name}"
  db_name                         = "${var.db_name}"

  engine                          = "${var.mysql_version}"
  machine_type                    = "${var.machine_type}"

  master_user_password            = "${var.master_user_password}"
  master_user_name                = "${var.master_user_name}"
  master_user_host                = "%"
  enable_public_internet_access   = "${var.enable_public_internet_access}"

  # Never do this in production!
  # We're setting permissive network rules to make
  # it easier to test the instance
  authorized_networks = [
    {
      name = "allow-all-inbound",
      value = "0.0.0.0/0"
    }
  ]

  # Set auto-increment flags to test the
  # feature in during automated testing
  database_flags = [
    {
      name  = "auto_increment_increment"
      value = "5"
    },
    {
      name  = "auto_increment_offset"
      value = "5"
    }
  ]
}

