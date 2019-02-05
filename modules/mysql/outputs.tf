output "instance_name" {
  description = "The name of the database instance"
  value       = "${google_sql_database_instance.master.name}"
}

output "public_ip" {
  description = "The IPv4 address of the master database instance"
  value       = "${var.publicly_accessible ? google_sql_database_instance.master.ip_address.0.ip_address : ""}"
}

output "instance_self_link" {
  description = "Self link to the master instance"
  value       = "${google_sql_database_instance.master.self_link}"
}

output "db_name" {
  description = "Name of the default database"
  value = "${google_sql_database.default.name}"
}

output "proxy_connection" {
  value = "${var.project}:${var.region}:${google_sql_database_instance.master.name}"
}

output "db_self_link" {
  description = "Self link to the default database"
  value       = "${google_sql_database.default.self_link}"
}

