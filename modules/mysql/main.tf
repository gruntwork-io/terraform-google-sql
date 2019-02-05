# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY A CLOUD SQL CLUSTER
# This module deploys an Cloud SQL cluster. The cluster is managed by Google and automatically handles leader
# election, replication, failover, backups, patching, and encryption.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ------------------------------------------------------------------------------
# CREATE THE CLOUD SQL CLUSTER
#
# NOTE: We have multiple google_sql_database_instance resources, based on
# HA, encryption and replication configuration options.
# ------------------------------------------------------------------------------

resource "google_sql_database_instance" "default" {
  name                 = "${var.name}"
  project              = "${var.project}"
  region               = "${var.region}"
  database_version     = "${var.engine}"
  master_instance_name = "${var.master_instance_name}"

  settings {
    tier                        = "${var.machine_type}"
    activation_policy           = "${var.activation_policy}"
    authorized_gae_applications = ["${var.authorized_gae_applications}"]
    disk_autoresize             = "${var.disk_autoresize}"
    backup_configuration        = ["${var.backup_configuration}"]
    ip_configuration            = ["${var.ip_configuration}"]
    location_preference         = ["${var.location_preference}"]
    maintenance_window          = ["${var.maintenance_window}"]
    disk_size                   = "${var.disk_size}"
    disk_type                   = "${var.disk_type}"
    pricing_plan                = "${var.pricing_plan}"
    replication_type            = "${var.replication_type}"
    database_flags              = ["${var.flags}"]
    availability_type           = "${var.availability_type}"
  }

  replica_configuration = ["${var.replica_configuration}"]
}

# ------------------------------------------------------------------------------
# CREATE A DATABASE
# ------------------------------------------------------------------------------

resource "google_sql_database" "default" {
  count     = "${var.master_instance_name == "" ? 1 : 0}"
  name      = "${var.db_name}"
  project   = "${var.project}"
  instance  = "${google_sql_database_instance.default.name}"
  charset   = "${var.db_charset}"
  collation = "${var.db_collation}"
}

resource "google_sql_user" "default" {
  count    = "${var.master_instance_name == "" ? 1 : 0}"
  name     = "${var.db_name}"
  project  = "${var.project}"
  instance = "${google_sql_database_instance.default.name}"
  host     = "${var.db_user_host}"
  password = "${var.db_password}"
}