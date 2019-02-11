output "master_instance_name" {
  description = "The name of the database instance"
  value       = "${google_sql_database_instance.master.name}"
}

output "master_ip_addresses" {
  description = "All IP addresses of the instance as list of maps, see https://www.terraform.io/docs/providers/google/r/sql_database_instance.html#ip_address-0-ip_address"
  value       = "${ google_sql_database_instance.master.ip_address }"
}

output "master_first_ip_address" {
  description = "The first IPv4 address of the addresses assigned to the instance. If the instance has only public IP, it is the public IP address. If it has only private IP, it the private IP address. If it has both, it is the first item in the list and full IP address details are in 'instance_ip_addresses'"
  value       = "${ google_sql_database_instance.master.first_ip_address }"
}

output "master_instance" {
  description = "Self link to the master instance"
  value       = "${google_sql_database_instance.master.self_link}"
}

output "master_proxy_connection" {
  description = "Instance path for connecting with Cloud SQL Proxy. Read more at https://cloud.google.com/sql/docs/mysql/sql-proxy"
  value       = "${var.project}:${var.region}:${google_sql_database_instance.master.name}"
}

output "master_ca_cert" {
  value       = "${google_sql_database_instance.master.server_ca_cert.0.cert}"
  description = "The CA Certificate used to connect to the SQL Instance via SSL"
}

output "master_ca_cert_common_name" {
  value       = "${google_sql_database_instance.master.server_ca_cert.0.common_name}"
  description = "The CN valid for the CA Cert"
}

output "master_ca_cert_create_time" {
  value       = "${google_sql_database_instance.master.server_ca_cert.0.create_time}"
  description = "Creation time of the CA Cert"
}

output "master_ca_cert_expiration_time" {
  value       = "${google_sql_database_instance.master.server_ca_cert.0.expiration_time}"
  description = "Expiration time of the CA Cert"
}

output "master_ca_cert_sha1_fingerprint" {
  value       = "${google_sql_database_instance.master.server_ca_cert.0.sha1_fingerprint}"
  description = "SHA Fingerprint of the CA Cert"
}

output "db" {
  description = "Self link to the default database"
  value       = "${google_sql_database.default.self_link}"
}

output "db_name" {
  description = "Name of the default database"
  value       = "${google_sql_database.default.name}"
}

output "complete" {
  description = "Name of the default database"
  value       = "${null_resource.complete.id}"
}
