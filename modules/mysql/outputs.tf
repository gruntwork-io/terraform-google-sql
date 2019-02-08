output "instance_name" {
  description = "The name of the database instance"
  value       = "${google_sql_database_instance.master.name}"
}

output "ip_addresses" {
  description = "All IP addresses of the instance as list of maps, see https://www.terraform.io/docs/providers/google/r/sql_database_instance.html#ip_address-0-ip_address"
  value       = "${ google_sql_database_instance.master.ip_address }"
}

output "first_ip_address" {
  description = "The first IPv4 address of the addresses assigned to the instance. If the instance has only public IP, it is the public IP address. If it has only private IP, it the private IP address. If it has both, it is the first item in the list and full IP address details are in 'instance_ip_addresses'"
  value       = "${ google_sql_database_instance.master.first_ip_address }"
}

output "instance" {
  description = "Self link to the master instance"
  value       = "${google_sql_database_instance.master.self_link}"
}

output "db_name" {
  description = "Name of the default database"
  value       = "${google_sql_database.default.name}"
}

output "proxy_connection" {
  description = "Instance path for connecting with Cloud SQL Proxy. Read more at https://cloud.google.com/sql/docs/mysql/sql-proxy"
  value       = "${var.project}:${var.region}:${google_sql_database_instance.master.name}"
}

output "db" {
  description = "Self link to the default database"
  value       = "${google_sql_database.default.self_link}"
}
