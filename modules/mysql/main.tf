# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY A CLOUD SQL CLUSTER
# This module deploys a Cloud SQL MySQL cluster. The cluster is managed by Google and automatically handles leader
# election, replication, failover, backups, patching, and encryption.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ------------------------------------------------------------------------------
# CREATE THE CLOUD SQL MYSQL CLUSTER
#
# NOTE: We have multiple google_sql_database_instance resources, based on
# HA, encryption and replication configuration options.
# ------------------------------------------------------------------------------

resource "google_sql_database_instance" "master" {
  provider = "google-beta"
  name                 = "${var.name}"
  project              = "${var.project}"
  region               = "${var.region}"
  database_version     = "${var.engine}"

  settings {
    tier                        = "${var.machine_type}"
    activation_policy           = "${var.activation_policy}"
    authorized_gae_applications = ["${var.authorized_gae_applications}"]
    disk_autoresize             = "${var.disk_autoresize}"

    ip_configuration {
      authorized_networks = ["${var.authorized_networks}"],
      ipv4_enabled = "${var.enable_public_internet_access}"
    }

    location_preference {
      follow_gae_application = "${var.follow_gae_application}"
      zone = "${var.zone}"
    }

    disk_size                   = "${var.disk_size}"
    disk_type                   = "${var.disk_type}"
    database_flags              = ["${var.database_flags}"]
    availability_type           = "${var.availability_type}"
  }
}

# ------------------------------------------------------------------------------
# CREATE A DATABASE
# ------------------------------------------------------------------------------

resource "google_sql_database" "default" {
  name      = "${var.db_name}"
  project   = "${var.project}"
  instance  = "${google_sql_database_instance.master.name}"
  charset   = "${var.db_charset}"
  collation = "${var.db_collation}"
}

resource "google_sql_user" "default" {
  name     = "${var.master_username}"
  project  = "${var.project}"
  instance = "${google_sql_database_instance.master.name}"
  host     = "${var.master_host}"
  password = "${var.master_password}"
}
