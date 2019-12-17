# Core Cloud SQL Concepts

## What is Cloud SQL?

Cloud SQL is Google's fully-managed database service that makes it easy to set up, maintain, manage, and administer
your relational databases on Google Cloud Platform. Cloud SQL automatically includes:

- Data replication between multiple zones with automatic failover.
- Automated and on-demand backups, and point-in-time recovery.
- Data encryption on networks, database tables, temporary files, and backups.
- Secure external connections with the [Cloud SQL Proxy](https://cloud.google.com/sql/docs/mysql/sql-proxy) or with the SSL/TLS protocol.

You can learn more about Cloud SQL from [the official documentation](https://cloud.google.com/sql/docs/).

## How do you connect to the database?

**Cloud SQL instances are created in a producer network (a VPC network internal to Google). They are not created in your VPC network. See https://cloud.google.com/sql/docs/mysql/private-ip**

You can use both public IP and private IP to connect to a Cloud SQL instance. 
Neither connection method affects the other; you must protect the public IP connection whether the instance is configured to use private IP or not.

You can also use the [Cloud SQL Proxy for MySQL](https://cloud.google.com/sql/docs/mysql/sql-proxy) and [Cloud SQL Proxy for PostgreSQL](https://cloud.google.com/sql/docs/postgres/sql-proxy) 
to connect to an instance that is also configured to use private IP. The proxy can connect using either the private IP address or a public IP address.

This module provides the connection details as [Terraform output 
variables](https://www.terraform.io/intro/getting-started/outputs.html). Use the public / private addresses depending on your configuration:


1. **Master Public IP Address** `master_public_ip_address`: The public IPv4 address of the master instance.
1. **Master Private IP Address** `master_private_ip_address`: The private IPv4 address of the master instance.
1. **Master Proxy connection** `master_proxy_connection`: Instance path for connecting with Cloud SQL Proxy; see [Connecting mysql Client Using the Cloud SQL Proxy](https://cloud.google.com/sql/docs/mysql/connect-admin-proxy).
1. **Read Replica Public IP Addresses** `read_replica_public_ip_addresses`: A list of read replica public IP addresses in the cluster. Use these addresses for reads (see "How do you scale this database?" below).
1. **Read Replica Private IP Addresses** `read_replica_private_ip_addresses`: A list of read replica private IP addresses in the cluster. Use these addresses for reads (see "How do you scale this database?" below).
1. **Read Replica Proxy Connections** `read_replica_proxy_connections`: A list of instance paths for connecting with Cloud SQL Proxy; see [Connecting Using the Cloud SQL Proxy](https://cloud.google.com/sql/docs/mysql/connect-admin-proxy).


You can programmatically extract these variables in your Terraform templates and pass them to other resources. 
You'll also see the variables at the end of each `terraform apply` call or if you run `terraform output`.

For full connectivity options and detailed documentation, see [Connecting to Cloud SQL MySQL from External Applications](https://cloud.google.com/sql/docs/mysql/connect-external-app) and [Connecting to Cloud SQL PostgreSQL from External Applications](https://cloud.google.com/sql/docs/postgres/external-connection-methods).

## How do you configure High Availability?

You can enable High Availability using the `enable_failover_replica` input variable.

### High Availability for MySQL

The configuration is made up of a primary instance (master) in the primary zone (`master_zone` input variable) and a failover replica in the secondary zone (`failover_replica_zone` input variable).
The failover replica is configured with the same database flags, users and passwords, authorized applications and networks, and databases as the primary instance.

For full details about MySQL High Availability, see https://cloud.google.com/sql/docs/mysql/high-availability

### High Availability for PostgreSQL

A Cloud SQL PostgreSQL instance configured for HA is also called a _regional instance_ and is located in a primary and secondary zone within the configured region. Within a regional instance, 
the configuration is made up of a primary instance (master) and a standby instance. You control the primary zone for the master instance
with input variable `master_zone` and Google will automatically place the standby instance in another zone. 

For full details about PostgreSQL High Availability, see https://cloud.google.com/sql/docs/postgres/high-availability


## How do you secure the database?

Cloud SQL customer data is encrypted when stored in database tables, temporary files, and backups. 
External connections can be encrypted by using SSL, or by using the Cloud SQL Proxy, which automatically encrypts traffic to and from the database.
If you do not use the proxy, you can enforce SSL for external connections using the `require_ssl` input variable.

For further information, see https://cloud.google.com/blog/products/gcp/best-practices-for-securing-your-google-cloud-databases and 
https://cloud.google.com/sql/faq#encryption

## How do you scale the database?

* **Storage**: Cloud SQL manages storage for you, automatically growing cluster volume up to 10TB You can set the 
  initial disk size using the `disk_size` input variable.
* **Vertical scaling**: To scale vertically (i.e. bigger DB instances with more CPU and RAM), use the `machine_type` 
  input variable. For a list of Cloud SQL Machine Types, see [Cloud SQL Pricing](https://cloud.google.com/sql/pricing#2nd-gen-pricing).
* **Horizontal scaling**: To scale horizontally, you can add more replicas using the `num_read_replicas` and `read_replica_zones` input variables, 
  and the module will automatically deploy the new instances, sync them to the master, and make them available as read 
  replicas.
