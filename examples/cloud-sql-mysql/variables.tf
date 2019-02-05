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

# Note, after a name is used, it cannot be reused for up to one week.
variable "name" {
  description = "The name of the database instance. Use lowercase letters, numbers, and hyphens. Start with a letter."
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
variable "publicly_accessible" {
  default = "true"
}

variable "mysql_version" {
  description = "The engine version of the database, e.g. `MYSQL_5_6` or `MYSQL_5_7`."
  default = "MYSQL_5_7"
}

variable "machine_type" {
  default = "db-f1-micro"
}

variable "db_name" {
  default     = "default"
}
