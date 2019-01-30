# Cloud SQL Module

This module creates a [Google Cloud SQL](https://cloud.google.com/sql/) cluster. The cluster is managed by Google, 
automating backups, replication, patches, and updates. 

You can use Cloud SQL with either [MySQL](https://cloud.google.com/sql/docs/mysql/) or [PostgreSQL](https://cloud.google.com/sql/docs/postgres/).

## How do you use this module?

See the [examples](/examples) folder for an example. 

## How do you connect to the database?

This module provides the connection details as [Terraform output 
variables](https://www.terraform.io/intro/getting-started/outputs.html):

1. **Cluster endpoint**: The endpoint for the whole cluster. You should always use this URL for writes, as it points to 
   the primary.
1. **Instance endpoints**: A comma-separated list of all DB instance URLs in the cluster, including the primary and all
   read replicas. Use these URLs for reads (see "How do you scale this DB?" below).
1. **Port**: The port to use to connect to the endpoints above.

TODO: Connectivity and output

For more info, see [Connecting to Cloud SQL from External Applications](https://cloud.google.com/sql/docs/mysql/connect-external-app).

You can programmatically extract these variables in your Terraform templates and pass them to other resources (e.g. 
pass them to User Data in your EC2 instances). You'll also see the variables at the end of each `terraform apply` call 
or if you run `terraform output`.

## How do you scale this database?

* **Storage**: Cloud SQL manages storage for you, automatically growing cluster volume up to 10TB.
* **Vertical scaling**: To scale vertically (i.e. bigger DB instances with more CPU and RAM), use the `machine_type` 
  input variable. For a list of Cloud SQL Machine Types, see [Cloud SQL Pricing](https://cloud.google.com/sql/pricing#2nd-gen-pricing).
* **Horizontal scaling**: To scale horizontally, you can add more replicas using the `instance_count` input variable, 
  and Aurora will automatically deploy the new instances, sync them to the master, and make them available as read 
  replicas.

## How do you configure this module?

This module allows you to configure a number of parameters, such as backup windows, maintenance window, port number,
and encryption. For a list of all available variables and their descriptions, see [variables.tf](./variables.tf).

## Known Issues

### Instance Recovery

Due to limitations on the current `terraform` provider for Google, it is not possible to restore backups with `terraform`. 
See https://github.com/terraform-providers/terraform-provider-google/issues/2446


