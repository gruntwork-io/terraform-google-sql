# ------------------------------------------------------------------------------
# MASTER OUTPUTS
# ------------------------------------------------------------------------------

output "master_instance_name" {
  description = "The name of the database instance"
  value       = "${module.postgres.master_instance_name}"
}

output "master_private_ip" {
  description = "The private IPv4 address of the master instance"
  value       = "${module.postgres.master_private_ip_address}"
}

output "master_instance" {
  description = "Self link to the master instance"
  value       = "${module.postgres.master_instance}"
}

output "master_proxy_connection" {
  description = "Instance path for connecting with Cloud SQL Proxy. Read more at https://cloud.google.com/sql/docs/mysql/sql-proxy"
  value       = "${module.postgres.master_proxy_connection}"
}

# ------------------------------------------------------------------------------
# DB OUTPUTS
# ------------------------------------------------------------------------------

output "db_name" {
  description = "Name of the default database"
  value       = "${module.postgres.db_name}"
}

output "db" {
  description = "Self link to the default database"
  value       = "${module.postgres.db}"
}
