output "instance_name" {
  description = "The name of the database instance"
  value       = "${google_sql_database_instance.master.name}"
}

output "public_ip" {
  description = "The IPv4 address of the master database instance"
  value       = "${var.publicly_accessible ? google_sql_database_instance.master.ip_address.0.ip_address : ""}"
}

output "instance" {
  description = "Self link to the master instance"
  value       = "${google_sql_database_instance.master.self_link}"
}

output "db_name" {
  description = "Name of the default database"
  value = "${google_sql_database.default.name}"
}


output "proxy_connection" {
  description = "Instance path for connecting with Cloud SQL Proxy. Read more at https://cloud.google.com/sql/docs/mysql/sql-proxy"
  value = "${var.project}:${var.region}:${google_sql_database_instance.master.name}"
}

output "db" {
  description = "Self link to the default database"
  value       = "${google_sql_database.default.self_link}"
}

