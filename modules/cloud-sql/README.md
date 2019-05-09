# Cloud SQL Module

<!-- NOTE: We use absolute linking here instead of relative linking, because the terraform registry does not support
           relative linking correctly.
-->

This module creates a [Google Cloud SQL](https://cloud.google.com/sql/) cluster. 
The cluster is managed by Google, automating backups, replication, patches, and updates. 

This module helps you run [MySQL](https://cloud.google.com/sql/docs/mysql/) and [PostgreSQL](https://cloud.google.com/sql/docs/postgres/) databases in [Google Cloud](https://cloud.google.com/).

## How do you use this module?

See the [examples](https://github.com/gruntwork-io/terraform-google-sql/tree/master/examples) folder for an example. 

## How do you configure this module?

This module allows you to configure a number of parameters, such as high availability, backup windows, maintenance window and replicas. 
For a list of all available variables and their descriptions, see [variables.tf](https://github.com/gruntwork-io/terraform-google-sql/blob/master/modules/cloud-sql/variables.tf).

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


## How do you secure this database?

Cloud SQL customer data is encrypted when stored in database tables, temporary files, and backups. 
External connections can be encrypted by using SSL, or by using the Cloud SQL Proxy, which automatically encrypts traffic to and from the database.
If you do not use the proxy, you can enforce SSL for external connections using the `require_ssl` input variable.

For further information, see https://cloud.google.com/blog/products/gcp/best-practices-for-securing-your-google-cloud-databases and 
https://cloud.google.com/sql/faq#encryption

## How do you scale this database?

* **Storage**: Cloud SQL manages storage for you, automatically growing cluster volume up to 10TB You can set the 
initial disk size using the `disk_size` input variable.
* **Vertical scaling**: To scale vertically (i.e. bigger DB instances with more CPU and RAM), use the `machine_type` 
  input variable. For a list of Cloud SQL Machine Types, see [Cloud SQL Pricing](https://cloud.google.com/sql/pricing#2nd-gen-pricing).
* **Horizontal scaling**: To scale horizontally, you can add more replicas using the `num_read_replicas` and `read_replica_zones` input variables, 
  and the module will automatically deploy the new instances, sync them to the master, and make them available as read 
  replicas.

## Known Issues

### Instance Recovery

Due to limitations on the current `terraform` provider for Google, it is not possible to restore backups with `terraform`. 

See https://github.com/terraform-providers/terraform-provider-google/issues/2446

### Read Replica and IP Addresses Outputs

Retrieving and outputting distinct values from list of maps is not possible with resources using `count` prior to `terraform 0.12`. 
Instead we have to output the values JSON encoded - for example `read_replica_server_ca_certs`. For full details of the outputs and 
their format, see [outputs.tf](https://github.com/gruntwork-io/terraform-google-sql/blob/master/modules/cloud-sql/outputs.tf).

See https://github.com/hashicorp/terraform/issues/17048


