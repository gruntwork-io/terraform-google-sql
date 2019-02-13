# ------------------------------------------------------------------------------
# MASTER OUTPUTS
# ------------------------------------------------------------------------------

output "master_instance_name" {
  description = "The name of the database instance"
  value       = "${module.mysql.master_instance_name}"
}

output "master_ip_addresses" {
  description = "All IP addresses of the instance as list of maps, see https://www.terraform.io/docs/providers/google/r/sql_database_instance.html#ip_address-0-ip_address"
  value       = "${module.mysql.master_ip_addresses}"
}

output "master_public_ip" {
  description = "The first IPv4 address of the addresses assigned to the master instance. As this instance has only public IP, it is the public IP address."
  value       = "${module.mysql.master_first_ip_address}"
}

output "master_instance" {
  description = "Self link to the master instance"
  value       = "${module.mysql.master_instance}"
}

output "master_proxy_connection" {
  description = "Instance path for connecting with Cloud SQL Proxy. Read more at https://cloud.google.com/sql/docs/mysql/sql-proxy"
  value       = "${module.mysql.master_proxy_connection}"
}

# ------------------------------------------------------------------------------
# DB OUTPUTS
# ------------------------------------------------------------------------------

output "db_name" {
  description = "Name of the default database"
  value       = "${module.mysql.db_name}"
}

output "db" {
  description = "Self link to the default database"
  value       = "${module.mysql.db}"
}

# ------------------------------------------------------------------------------
# FAILOVER REPLICA OUTPUTS
# ------------------------------------------------------------------------------

output "failover_instance" {
  description = "Self link to the failover instance"
  value       = "${module.mysql.failover_instance}"
}

output "failover_instance_name" {
  description = "The name of the failover database instance"
  value       = "${module.mysql.failover_instance_name}"
}

output "failover_public_ip" {
  description = "The first IPv4 address of the addresses assigned to the failover instance. As this instance has only public IP, it is the public IP address."
  value       = "${module.mysql.failover_first_ip_address}"
}

output "failover_proxy_connection" {
  description = "Failover instance path for connecting with Cloud SQL Proxy. Read more at https://cloud.google.com/sql/docs/mysql/sql-proxy"
  value       = "${module.mysql.failover_proxy_connection}"
}
