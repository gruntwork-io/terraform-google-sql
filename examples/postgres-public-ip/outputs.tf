# ------------------------------------------------------------------------------
# MASTER OUTPUTS
# ------------------------------------------------------------------------------

output "master_instance_name" {
  description = "The name of the database instance"
  value       = "${module.postgres.master_instance_name}"
}

output "master_ip_addresses" {
  description = "All IP addresses of the instance as list of maps, see https://www.terraform.io/docs/providers/google/r/sql_database_instance.html#ip_address-0-ip_address"
  value       = "${module.postgres.master_ip_addresses}"
}

output "master_public_ip" {
  description = "The first IPv4 address of the addresses assigned to the instance. As this instance has only public IP, it is the public IP address."
  value       = "${module.postgres.master_first_ip_address}"
}

output "master_ca_cert" {
  description = "The CA Certificate used to connect to the SQL Instance via SSL"
  value       = "${module.postgres.master_ca_cert}"
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
