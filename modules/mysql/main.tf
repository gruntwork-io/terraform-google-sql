# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY A CLOUD SQL CLUSTER
# This module deploys a Cloud SQL MySQL cluster. The cluster is managed by Google and automatically handles leader
# election, replication, failover, backups, patching, and encryption.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ------------------------------------------------------------------------------
# PREPARE LOCALS
#
# NOTE: Due to limitations in terraform and heavy use of nested sub-blocks in the resource,
# we have to construct some of the configuration values dynamically
# ------------------------------------------------------------------------------

locals {
  is_postgres = "${replace(var.engine, "POSTGRES", "") != var.engine}"
  is_mysql    = "${replace(var.engine, "MYSQL", "") != var.engine}"

  # Terraform does not allow using lists of maps with coditionals, so we have to
  # trick terraform by creating a string conditional first.
  # See https://github.com/hashicorp/terraform/issues/12453
  ip_configuration_key = "${var.private_network != "" ? "PRIVATE" : "PUBLIC"}"

  ip_configuration_def = {
    "PRIVATE" = [{
      authorized_networks = ["${var.authorized_networks}"]
      ipv4_enabled        = "${var.enable_public_internet_access}"
      private_network     = "${var.private_network}"
      require_ssl         = "${var.require_ssl}"
    }]

    "PUBLIC" = [{
      authorized_networks = ["${var.authorized_networks}"]
      ipv4_enabled        = "${var.enable_public_internet_access}"
      require_ssl         = "${var.require_ssl}"
    }]
  }

  # We have to construct the sub-block dynamically. If the user creates a public-ip only instance,
  # passing an empty string into 'private_network' causes
  # 'private_network" ("") doesn't match regexp "projects/...'
  ip_configuration = "${local.ip_configuration_def[local.ip_configuration_key]}"
}

# ------------------------------------------------------------------------------
# CREATE THE MASTER INSTANCE
#
# NOTE: We have multiple google_sql_database_instance resources, based on
# HA and replication configuration options.
# ------------------------------------------------------------------------------

resource "google_sql_database_instance" "master" {
  provider         = "google-beta"
  name             = "${var.name}"
  project          = "${var.project}"
  region           = "${var.region}"
  database_version = "${var.engine}"

  settings {
    tier                        = "${var.machine_type}"
    activation_policy           = "${var.activation_policy}"
    authorized_gae_applications = ["${var.authorized_gae_applications}"]
    disk_autoresize             = "${var.disk_autoresize}"

    ip_configuration = ["${local.ip_configuration}"]

    location_preference {
      follow_gae_application = "${var.follow_gae_application}"
      zone                   = "${var.master_zone}"
    }

    backup_configuration {
      binary_log_enabled = "${var.binary_log_enabled}"
      enabled            = "${var.backup_enabled}"
      start_time         = "${var.backup_start_time}"
    }

    maintenance_window {
      day          = "${var.maintenance_window_day}"
      hour         = "${var.maintenance_window_hour}"
      update_track = "${var.maintenance_track}"
    }

    disk_size         = "${var.disk_size}"
    disk_type         = "${var.disk_type}"
    database_flags    = ["${var.database_flags}"]
    availability_type = "${var.availability_type}"

    user_labels = "${var.custom_labels}"
  }

  # Default timeouts are 10 minutes, which in most cases should be enough.
  # Sometimes the database creation can, however, take longer, so we
  # increase the timeouts slightly.
  timeouts {
    create = "30m"
    delete = "30m"
    update = "30m"
  }

  depends_on = ["null_resource.wait_for"]
}

# ------------------------------------------------------------------------------
# CREATE A DATABASE
# ------------------------------------------------------------------------------

resource "google_sql_database" "default" {
  depends_on = ["google_sql_database_instance.master"]

  name      = "${var.db_name}"
  project   = "${var.project}"
  instance  = "${google_sql_database_instance.master.name}"
  charset   = "${var.db_charset}"
  collation = "${var.db_collation}"
}

resource "google_sql_user" "default" {
  depends_on = ["google_sql_database.default"]

  name     = "${var.master_user_name}"
  project  = "${var.project}"
  instance = "${google_sql_database_instance.master.name}"
  host     = "${var.master_user_host}"
  password = "${var.master_user_password}"
}

# ------------------------------------------------------------------------------
# CREATE A NULL RESOURCE TO EMULATE DEPENDENCIES
# ------------------------------------------------------------------------------
resource "null_resource" "wait_for" {
  triggers = {
    instance = "${var.wait_for}"
  }
}

# ------------------------------------------------------------------------------
# CREATE THE FAILOVER REPLICA
# ------------------------------------------------------------------------------

resource "google_sql_database_instance" "failover_replica" {
  count = "${var.enable_failover_replica}"

  depends_on = ["google_sql_user.default"]

  provider         = "google-beta"
  name             = "${var.name}-failover"
  project          = "${var.project}"
  region           = "${var.region}"
  database_version = "${var.engine}"

  # The name of the instance that will act as the master in the replication setup.
  master_instance_name = "${google_sql_database_instance.master.name}"

  replica_configuration {
    # Specifies that the replica is the failover target.
    failover_target = true
  }

  settings {
    crash_safe_replication = true

    tier                        = "${var.machine_type}"
    authorized_gae_applications = ["${var.authorized_gae_applications}"]
    disk_autoresize             = "${var.disk_autoresize}"

    ip_configuration = ["${local.ip_configuration}"]

    location_preference {
      follow_gae_application = "${var.follow_gae_application}"
      zone                   = "${var.failover_replica_zone}"
    }

    disk_size      = "${var.disk_size}"
    disk_type      = "${var.disk_type}"
    database_flags = ["${var.database_flags}"]

    user_labels = "${var.custom_labels}"
  }

  # Default timeouts are 10 minutes, which in most cases should be enough.
  # Sometimes the database creation can, however, take longer, so we
  # increase the timeouts slightly.
  timeouts {
    create = "30m"
    delete = "30m"
    update = "30m"
  }
}

# ------------------------------------------------------------------------------
# CREATE A TEMPLATE FILE TO SIGNAL ALL RESOURCES HAVE BEEN CREATED
# ------------------------------------------------------------------------------
data "template_file" "complete" {
  depends_on = ["google_sql_database_instance.failover_replica"]
  template   = "true"
}
