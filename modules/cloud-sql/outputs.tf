# ------------------------------------------------------------------------------
# MASTER INSTANCE OUTPUTS
# ------------------------------------------------------------------------------

output "master_instance_name" {
  description = "The name of the master database instance"
  value       = google_sql_database_instance.master.name
}

output "master_public_ip_address" {
  description = "The public IPv4 address of the master instance."
  value       = google_sql_database_instance.master.public_ip_address
}

output "master_private_ip_address" {
  description = "The public IPv4 address of the master instance."
  value       = google_sql_database_instance.master.private_ip_address
}

output "master_ip_addresses" {
  description = "All IP addresses of the master instance JSON encoded, see https://www.terraform.io/docs/providers/google/r/sql_database_instance.html#ip_address-0-ip_address"
  value       = jsonencode(google_sql_database_instance.master.ip_address)
}

output "master_instance" {
  description = "Self link to the master instance"
  value       = google_sql_database_instance.master.self_link
}

output "master_proxy_connection" {
  description = "Master instance path for connecting with Cloud SQL Proxy. Read more at https://cloud.google.com/sql/docs/mysql/sql-proxy"
  value       = "${var.project}:${var.region}:${google_sql_database_instance.master.name}"
}

# ------------------------------------------------------------------------------
# MASTER CERT OUTPUTS
# ------------------------------------------------------------------------------

output "master_ca_cert" {
  description = "The CA Certificate used to connect to the master instance via SSL"
  value       = google_sql_database_instance.master.server_ca_cert.0.cert
}

output "master_ca_cert_common_name" {
  description = "The CN valid for the master instance CA Cert"
  value       = google_sql_database_instance.master.server_ca_cert.0.common_name
}

output "master_ca_cert_create_time" {
  description = "Creation time of the master instance CA Cert"
  value       = google_sql_database_instance.master.server_ca_cert.0.create_time
}

output "master_ca_cert_expiration_time" {
  description = "Expiration time of the master instance CA Cert"
  value       = google_sql_database_instance.master.server_ca_cert.0.expiration_time
}

output "master_ca_cert_sha1_fingerprint" {
  description = "SHA Fingerprint of the master instance CA Cert"
  value       = google_sql_database_instance.master.server_ca_cert.0.sha1_fingerprint
}

# ------------------------------------------------------------------------------
# DATABASE OUTPUTS
# ------------------------------------------------------------------------------

output "db" {
  description = "Self link to the default database"
  value       = google_sql_database.default.self_link
}

output "db_name" {
  description = "Name of the default database"
  value       = google_sql_database.default.name
}

# ------------------------------------------------------------------------------
# FAILOVER REPLICA OUTPUTS - ONLY APPLICABLE TO MYSQL
# ------------------------------------------------------------------------------

output "failover_instance_name" {
  description = "The name of the failover database instance"
  value       = join("", google_sql_database_instance.failover_replica.*.name)
}

output "failover_public_ip_address" {
  description = "The public IPv4 address of the failover instance."
  value       = join("", google_sql_database_instance.failover_replica.*.public_ip_address)
}

output "failover_private_ip_address" {
  description = "The private IPv4 address of the failover instance."
  value       = join("", google_sql_database_instance.failover_replica.*.private_ip_address)
}

output "failover_ip_addresses" {
  description = "All IP addresses of the failover instance JSON encoded, see https://www.terraform.io/docs/providers/google/r/sql_database_instance.html#ip_address-0-ip_address"
  value       = jsonencode(google_sql_database_instance.failover_replica.*.ip_address)
}

output "failover_instance" {
  description = "Self link to the failover instance"
  value       = join("", google_sql_database_instance.failover_replica.*.self_link)
}

output "failover_proxy_connection" {
  description = "Failover instance path for connecting with Cloud SQL Proxy. Read more at https://cloud.google.com/sql/docs/mysql/sql-proxy"
  value       = local.failover_proxy_connection
}

# ------------------------------------------------------------------------------
# FAILOVER CERT OUTPUTS - ONLY APPLICABLE TO MYSQL
# ------------------------------------------------------------------------------

output "failover_replica_ca_cert" {
  description = "The CA Certificate used to connect to the failover instance via SSL"
  value       = local.failover_certificate
}

output "failover_replica_ca_cert_common_name" {
  description = "The CN valid for the failover instance CA Cert"
  value       = local.failover_certificate_common_name
}

output "failover_replica_ca_cert_create_time" {
  description = "Creation time of the failover instance CA Cert"
  value       = local.failover_certificate_create_time
}

output "failover_replica_ca_cert_expiration_time" {
  description = "Expiration time of the failover instance CA Cert"
  value       = local.failover_certificate_expiration_time
}

output "failover_replica_ca_cert_sha1_fingerprint" {
  description = "SHA Fingerprint of the failover instance CA Cert"
  value       = local.failover_certificate_sha1_fingerprint
}

# ------------------------------------------------------------------------------
# READ REPLICA OUTPUTS
# ------------------------------------------------------------------------------

output "read_replica_instance_names" {
  description = "List of names for the read replica instances"
  value       = google_sql_database_instance.read_replica.*.name
}

output "read_replica_ip_addresses" {
  description = "All IP addresses of the read replica instances JSON encoded, see https://www.terraform.io/docs/providers/google/r/sql_database_instance.html#ip_address-0-ip_address"
  value       = jsonencode(google_sql_database_instance.read_replica.*.ip_address)
}

output "read_replica_public_ip_addresses" {
  description = "List of public IPv4 addresses of the read replica instances."
  value       = google_sql_database_instance.read_replica.*.public_ip_address
}

output "read_replica_private_ip_addresses" {
  description = "List of private IPv4 addresses of the read replica instances."
  value       = google_sql_database_instance.read_replica.*.private_ip_address
}

output "read_replica_instances" {
  description = "List of self links to the read replica instances"
  value       = google_sql_database_instance.read_replica.*.self_link
}

output "read_replica_proxy_connections" {
  description = "List of read replica instance paths for connecting with Cloud SQL Proxy. Read more at https://cloud.google.com/sql/docs/mysql/sql-proxy"
  value       = data.template_file.read_replica_proxy_connection.*.rendered
}

output "read_replica_server_ca_certs" {
  description = "JSON encoded list of CA Certificates used to connect to the read replica instances via SSL"
  value       = jsonencode(google_sql_database_instance.read_replica.*.server_ca_cert)
}

# ------------------------------------------------------------------------------
# MISC OUTPUTS
# ------------------------------------------------------------------------------

output "complete" {
  description = "Output signaling that all resources have been created"
  value       = data.template_file.complete.rendered
}

output "service_account_email_address" {
  description = "Service account email address associated with the CloudSQL instance"
  value       = google_sql_database_instance.master.service_account_email_address
}
