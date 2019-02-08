output "instance_name" {
  description = "The name of the database instance"
  value       = "${module.mysql.instance_name}"
}

output "ip_addresses" {
  description = "All IP addresses of the instance as list of maps, see https://www.terraform.io/docs/providers/google/r/sql_database_instance.html#ip_address-0-ip_address"
  value       = "${module.mysql.ip_addresses}"
}

output "private_ip" {
  description = "The first IPv4 address of the addresses assigned to the instance. As this instance has only private IP, it is the private IP address."
  value       = "${module.mysql.first_ip_address}"
}

output "instance" {
  description = "Self link to the master instance"
  value       = "${module.mysql.instance}"
}

output "db_name" {
  description = "Name of the default database"
  value       = "${module.mysql.db_name}"
}

output "proxy_connection" {
  value = "${module.mysql.proxy_connection}"
}

output "db" {
  description = "Self link to the default database"
  value       = "${module.mysql.db}"
}
