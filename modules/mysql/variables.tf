# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables are expected to be passed in by the operator
# ---------------------------------------------------------------------------------------------------------------------

variable "project" {
  description = "The project ID to host the database in."
}

variable "region" {
  description = "The region to host the database in."
}

variable "name" {
  description = "The name of the database instance. Note, after a name is used, it cannot be reused for up to one week. Use lowercase letters, numbers, and hyphens. Start with a letter."
}

variable "engine" {
  description = "The engine version of the database, e.g. `MYSQL_5_6` or `MYSQL_5_7`. See https://cloud.google.com/sql/docs/features for supported versions."
}

variable "machine_type" {
  description = "The machine type for the instances. See this page for supported tiers and pricing: https://cloud.google.com/sql/pricing"
}

variable "db_name" {
  description = "Name of your database. Needs to follow MySQL identifier rules: https://dev.mysql.com/doc/refman/5.7/en/identifiers.html"
}

variable "master_user_name" {
  description = "The username part for the default user credentials, i.e. 'master_user_name'@'master_user_host' IDENTIFIED BY 'master_user_password'. This should typically be set as the environment variable TF_VAR_master_user_name so you don't check it into source control."
}

variable "master_user_password" {
  description = "The password part for the default user credentials, i.e. 'master_user_name'@'master_user_host' IDENTIFIED BY 'master_user_password'. This should typically be set as the environment variable TF_VAR_master_user_password so you don't check it into source control."
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# Generally, these values won't need to be changed.
# ---------------------------------------------------------------------------------------------------------------------

variable "activation_policy" {
  description = "This specifies when the instance should be active. Can be either `ALWAYS`, `NEVER` or `ON_DEMAND`."
  default     = "ALWAYS"
}

variable "authorized_networks" {
  description = "A list of authorized CIDR-formatted IP address ranges that can connect to this DB. Only applies to public IP instances."
  type        = "list"
  default     = []

  # Example:
  #
  # authorized_networks = [
  #   {
  #     name = "all-inbound" # optional
  #     value = "0.0.0.0/0"
  #   }
  # ]
}

variable "authorized_gae_applications" {
  description = "A list of Google App Engine (GAE) project names that are allowed to access this instance."
  type        = "list"
  default     = []
}

variable "availability_type" {
  description = "This specifies whether a PostgreSQL instance should be set up for high availability (REGIONAL) or single zone (ZONAL)."
  default     = "ZONAL"
}

variable "backup_enabled" {
  description = "Set to false if you want to disable backup."
  default     = true
}

variable "backup_start_time" {
  description = "HH:MM format (e.g. 04:00) time indicating when backup configuration starts. NOTE: Start time is randomly assigned if backup is enabled and 'backup_start_time' is not set"
  default     = "04:00"
}

variable "binary_log_enabled" {
  description = "Set to false if you want to disable binary logs. Note, when using failover or read replicas, master and existing backups need to have binary_log_enabled=true set."
  default     = true
}

variable "maintenance_window_day" {
  description = "Day of week (1-7), starting on Monday, on which system maintenance can occur. Performance may be degraded or there may even be a downtime during maintenance windows."
  default     = 7
}

variable "maintenance_window_hour" {
  description = "Hour of day (0-23) on which system maintenance can occur. Ignored if 'maintenance_window_day' not set. Performance may be degraded or there may even be a downtime during maintenance windows."
  default     = 7
}

variable "maintenance_track" {
  description = "Receive updates earlier (canary) or later (stable)."
  default     = "stable"
}

variable "db_charset" {
  description = "The charset for the default database."
  default     = ""
}

variable "db_collation" {
  description = "The collation for the default database. Example for MySQL databases: 'utf8_general_ci'."
  default     = ""
}

variable "database_flags" {
  description = "List of Cloud SQL flags that are applied to the database server"
  type        = "list"
  default     = []

  # Example:
  #
  # database_flags = [
  #  {
  #    name  = "auto_increment_increment"
  #    value = "10"
  #  },
  #  {
  #    name  = "auto_increment_offset"
  #    value = "5"
  #  },
  #]
}

variable "disk_autoresize" {
  description = "Second Generation only. Configuration to increase storage size automatically."
  default     = true
}

variable "disk_size" {
  description = "Second generation only. The size of data disk, in GB. Size of a running instance cannot be reduced but can be increased."
  default     = 10
}

variable "disk_type" {
  description = "The type of storage to use. Must be one of `PD_SSD` or `PD_HDD`."
  default     = "PD_SSD"
}

variable "follow_gae_application" {
  description = "A GAE application whose zone to remain in. Must be in the same region as this instance."
  default     = ""
}

variable "master_zone" {
  description = "Preferred zone for the master instance (e.g. 'us-central1-a'). 'region'. If empty, Google will auto-assign a zone."
  default     = ""
}

variable "master_user_host" {
  description = "The host part for the default user, i.e. 'master_user_name'@'master_user_host' IDENTIFIED BY 'master_user_password' "
  default     = "%"
}

# In nearly all cases, databases should NOT be publicly accessible, however if you're migrating from a PAAS provider like Heroku to GCP, this needs to remain open to the internet.
variable "enable_public_internet_access" {
  description = "WARNING: - In nearly all cases a database should NOT be publicly accessible. Only set this to true if you want the database open to the internet."
  default     = false
}

variable "enable_failover_replica" {
  description = "Set to true to enable failover replica."
  default     = false
}

variable "failover_replica_zone" {
  description = "The preferred zone for the failover instance (e.g. 'us-central1-b'). Must be different than 'master_zone'."
  default     = ""
}

variable "require_ssl" {
  description = "True if the instance should require SSL/TLS for users connecting over IP. Note: SSL/TLS is needed to provide security when you connect to Cloud SQL using IP addresses. If you are connecting to your instance only by using the Cloud SQL Proxy or the Java Socket Library, you do not need to configure your instance to use SSL/TLS."
  default     = false
}

variable "private_network" {
  description = "The resource link for the VPC network from which the Cloud SQL instance is accessible for private IP."
  default     = ""
}

variable "num_read_replicas" {
  description = "The number of read replicas to create. Cloud SQL will replicate all data from the master to these replicas, which you can use to horizontally scale read traffic."
  default     = 0
}

variable "read_replica_zones" {
  description = "A list of compute zones where read replicas should be created. List size should match 'num_read_replicas'"
  type        = "list"
  default     = []

  # Example:
  #  default = ["us-central1-b", "us-central1-c"]
}

variable "custom_labels" {
  description = "A map of custom labels to apply to the instance. The key is the label name and the value is the label value."
  type        = "map"
  default     = {}
}

variable "wait_for" {
  description = "By passing a value to this variable, you can effectively tell this module to wait to deploy until the given variable's value is resolved, which is a way to require that this module depend on some other module. Note that the actual value of this variable doesn't matter."
  default     = ""
}
