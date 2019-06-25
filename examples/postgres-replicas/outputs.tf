# ------------------------------------------------------------------------------
# MASTER OUTPUTS
# ------------------------------------------------------------------------------

output "master_instance_name" {
  description = "The name of the database instance"
  value       = module.postgres.master_instance_name
}

output "master_public_ip" {
  description = "The public IPv4 address of the master instance"
  value       = module.postgres.master_public_ip_address
}

output "master_instance" {
  description = "Self link to the master instance"
  value       = module.postgres.master_instance
}

output "master_proxy_connection" {
  description = "Instance path for connecting with Cloud SQL Proxy. Read more at https://cloud.google.com/sql/docs/mysql/sql-proxy"
  value       = module.postgres.master_proxy_connection
}

# ------------------------------------------------------------------------------
# DB OUTPUTS
# ------------------------------------------------------------------------------

output "db_name" {
  description = "Name of the default database"
  value       = module.postgres.db_name
}

output "db" {
  description = "Self link to the default database"
  value       = module.postgres.db
}

# ------------------------------------------------------------------------------
# READ REPLICA OUTPUTS
# ------------------------------------------------------------------------------

output "read_replica_instance_names" {
  description = "List of names for the read replica instances"
  value       = module.postgres.read_replica_instance_names
}

output "read_replica_public_ips" {
  description = "List of public IPv4 addresses of the read replica instances"
  value       = module.postgres.read_replica_public_ip_addresses
}

output "read_replica_instances" {
  description = "List of self links to the read replica instances"
  value       = module.postgres.read_replica_instances
}

output "read_replica_proxy_connections" {
  description = "List of read replica instance paths for connecting with Cloud SQL Proxy. Read more at https://cloud.google.com/sql/docs/mysql/sql-proxy"
  value       = module.postgres.read_replica_proxy_connections
}

# Although we don't use the values, this output highlights the JSON encoded output we use in certain
# cases where the resource output cannot properly be computed.
# See https://github.com/hashicorp/terraform/issues/17048
output "read_replica_server_ca_certs" {
  description = "JSON encoded list of CA Certificates used to connect to the read replica instances via SSL"
  value       = module.postgres.read_replica_server_ca_certs
}
