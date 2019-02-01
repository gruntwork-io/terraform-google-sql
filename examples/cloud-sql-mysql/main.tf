provider "google-beta" {
  region = "${var.region}"
  project = "${var.project}"
}

# Use Terraform 0.10.x so that we can take advantage of Terraform GCP functionality as a separate provider via
# https://github.com/terraform-providers/terraform-provider-google
terraform {
  required_version = ">= 0.10.3"
}

variable "region" {
  default = "europe-north1"
}

variable "project" {
  default = "dev-sandbox-228703"
}


variable "zone" {
  default = "europe-north1-a"
}

variable "mysql_version" {
  default = "MYSQL_5_6"
}

resource "random_id" "name" {
  byte_length = 2
}

resource "google_compute_network" "private_network" {
  provider = "google-beta"
  name       = "private-network"
}

resource "google_compute_global_address" "private_ip_address" {
  provider = "google-beta"
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type = "INTERNAL"
  prefix_length = 16
  network       = "${google_compute_network.private_network.self_link}"
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider = "google-beta"
  network       = "${google_compute_network.private_network.self_link}"
  service       = "servicenetworking.googleapis.com"
  reserved_peering_ranges = ["${google_compute_global_address.private_ip_address.name}"]
}


module "mysql-db" {
  source           = "../../modules/cloud-sql"
  name             = "example-mysql-${random_id.name.hex}"
  region = "${var.region}"
  engine = "${var.mysql_version}"
  project = "${var.project}"
  machine_type = "db-f1-micro"

  ip_configuration = [
    {
      ipv4_enabled = "true"
      private_network = "${google_compute_network.private_network.self_link}"
    }
  ]

  # https://cloud.google.com/sql/docs/mysql/flags
  flags = [
  ]
}

output "mysql_conn" {
  value = "${var.project}:${var.region}:${module.mysql-db.instance_name}"
}

