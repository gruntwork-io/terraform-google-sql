# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables are expected to be passed in by the operator
# ---------------------------------------------------------------------------------------------------------------------

variable "project" {
  description = "The project ID to host the database in."
  type        = string
}

variable "region" {
  description = "The region to host the database in."
  type        = string
}

# Note, after a name db instance is used, it cannot be reused for up to one week.
variable "common_name" {
  description = "The common name to be used in the certificate to identify the client. Constrained to [a-zA-Z.-_ ]+. Changing this forces a new resource to be created."
  type        = string
}

variable "database_instance_name" {
  description = "The name of the Cloud SQL instance. Changing this forces a new resource to be created."
  type        = string
}
