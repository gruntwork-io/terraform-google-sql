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

# Note, after a name db instance is used, it cannot be reused for up to one week.
variable "name_prefix" {
  description = "The name prefix for the database instance. Will be appended with a random string. Use lowercase letters, numbers, and hyphens. Start with a letter."
}

variable "master_user_name" {
  description = "The username for the master user."
}

variable "master_user_password" {
  description = "The password for the master user."
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# Generally, these values won't need to be changed.
# ---------------------------------------------------------------------------------------------------------------------
# In nearly all cases, databases should NOT be publicly accessible, however if you're migrating from a PAAS provider like Heroku to GCP, this needs to remain open to the internet.
variable "enable_public_internet_access" {
  description = "WARNING: - In nearly all cases a database should NOT be publicly accessible. Only set this to true if you want the database open to the internet"
  default     = true
}

variable "mysql_version" {
  description = "The engine version of the database, e.g. `MYSQL_5_6` or `MYSQL_5_7`"
  default = "MYSQL_5_7"
}

variable "machine_type" {
  default = "db-f1-micro"
}

variable "db_name" {
  description = "Name for the db"
  default     = "default"
}

variable "name_override" {
  description = "You may optionally override the name_prefix + random string by specifying an override"
  default = ""
}


