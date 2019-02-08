# MySQL Module

This module creates a [Google Cloud SQL](https://cloud.google.com/sql/) [MySQL](https://cloud.google.com/sql/docs/mysql/) cluster. 
The cluster is managed by Google, automating backups, replication, patches, and updates. 

This module helps you run [MySQL](https://cloud.google.com/sql/docs/mysql/), see [postgres](../postgresql) for running [PostgreSQL](https://cloud.google.com/sql/docs/postgres/).

## How do you use this module?

See the [examples](/examples) folder for an example. 

## How do you configure this module?

This module allows you to configure a number of parameters, such as backup windows, maintenance window, replicas
and encryption. For a list of all available variables and their descriptions, see [variables.tf](./variables.tf).

## How do you connect to the database?

**Cloud SQL instances are created in a producer network (a VPC network internal to Google). They are not created in your VPC network. See https://cloud.google.com/sql/docs/mysql/private-ip**
 
You can use both [public IP](https://cloud.google.com/sql/docs/mysql/connect-admin-ip) and [private IP](https://cloud.google.com/sql/docs/mysql/private-ip) to connect to a Cloud SQL instance. 
Neither connection method affects the other; you must protect the public IP connection whether the instance is configured to use private IP or not.

You can also use the [Cloud SQL Proxy](https://cloud.google.com/sql/docs/mysql/connect-admin-proxy) to connect to an instance that is also configured to use private IP. The proxy can connect using either the private IP address or a public IP address.

This module provides the connection details as [Terraform output 
variables](https://www.terraform.io/intro/getting-started/outputs.html):


1. **First IP Address** `first_ip_address`: The first IPv4 address of the addresses assigned to the instance. If the instance has only public IP, it is the [public IP address](https://cloud.google.com/sql/docs/mysql/connect-admin-ip). If it has only private IP, it the [private IP address](https://cloud.google.com/sql/docs/mysql/private-ip). If it has both, it is the first item in the list and full IP address details are in `instance_ip_addresses`.
1. **Proxy connection** `proxy_connection`: Instance path for connecting with Cloud SQL Proxy; see [Connecting mysql Client Using the Cloud SQL Proxy](https://cloud.google.com/sql/docs/mysql/connect-admin-proxy).
1. TODO: **Replica endpoints** `replica_endpoints`: A comma-separated list of all DB instance URLs in the cluster, including the primary and all
   read replicas. Use these URLs for reads (see "How do you scale this DB?" below).



You can programmatically extract these variables in your Terraform templates and pass them to other resources. 
You'll also see the variables at the end of each `terraform apply` call or if you run `terraform output`.

For full connectivity options and detailed documentation, see [Connecting to Cloud SQL from External Applications](https://cloud.google.com/sql/docs/mysql/connect-external-app).

## How do you scale this database?

* **Storage**: Cloud SQL manages storage for you, automatically growing cluster volume up to 10TB.
* **Vertical scaling**: To scale vertically (i.e. bigger DB instances with more CPU and RAM), use the `machine_type` 
  input variable. For a list of Cloud SQL Machine Types, see [Cloud SQL Pricing](https://cloud.google.com/sql/pricing#2nd-gen-pricing).
* **Horizontal scaling**: To scale horizontally, you can add more replicas using the `instance_count` input variable, 
  and the module will automatically deploy the new instances, sync them to the master, and make them available as read 
  replicas.

## Known Issues

### Instance Recovery

Due to limitations on the current `terraform` provider for Google, it is not possible to restore backups with `terraform`. 
See https://github.com/terraform-providers/terraform-provider-google/issues/2446


