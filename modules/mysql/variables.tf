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
  description = "The engine version of the database, e.g. `MYSQL_5_6` or `MYSQL_5_7`."
}

# TODO: Depending on how the replicas are set up, tweak this.
#variable "master_instance_name" {
#  description = "The name of the instance that will act as the master in the replication setup. Note, this requires the master to have binary_log_enabled set, as well as existing backups."
#  default     = ""
#}

variable "machine_type" {
  description = "The machine type for the instance. See this page for supported tiers and pricing: https://cloud.google.com/sql/pricing"
}

variable "db_name" {
  description = "Name of for your database of up to 8 alpha-numeric characters."
  default     = ""
}

variable "master_username" {
  description = "The username for the master user."
}

variable "master_password" {
  description = "The password for the master user."
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
  description = "A list of authorized CIDR-formatted IP address ranges that can connect to this DB."
  type        = "list"
  default = []
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
  type = "list"
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
  default     = "PD_HDD"
}

variable "follow_gae_application" {
  description = "A GAE application whose zone to remain in. Must be in the same region as this instance."
  default = ""
}

variable "zone" {
  description = "Preferred zone for the instance."
  default = ""
}

variable "master_host" {
  description = "The host for the default user"
  default     = "%"
}

# In nearly all cases, databases should NOT be publicly accessible, however if you're migrating from a PAAS provider like Heroku to GCP, this needs to remain open to the internet.
variable "enable_public_internet_access" {
  description = "WARNING: - In nearly all cases a database should NOT be publicly accessible. Only set this to true if you want the database open to the internet."
  default     = false
}