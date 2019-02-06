output "instance_name" {
  description = "The name of the database instance"
  value       = "${module.mysql.instance_name}"
}

output "public_ip" {
  description = "The IPv4 address of the master database instance"
  value       = "${module.mysql.public_ip}"
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
