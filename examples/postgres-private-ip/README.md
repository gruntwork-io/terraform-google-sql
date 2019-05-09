# PostgreSQL Cloud SQL Private IP Example

<!-- NOTE: We use absolute linking here instead of relative linking, because the terraform registry does not support
           relative linking correctly.
-->

This folder contains an example of how to use the [Cloud SQL module](https://github.com/gruntwork-io/terraform-google-sql/tree/master/modules/cloud-sql) to create a [Google Cloud SQL](https://cloud.google.com/sql/) 
[PostgreSQL](https://cloud.google.com/sql/docs/postgres/) database instance with a [private IP address](https://cloud.google.com/sql/docs/postgres/private-ip). 

## How do you run this example?

To run this example, you need to:

1. Install [Terraform](https://www.terraform.io/).
1. Open up `variables.tf` and set secrets at the top of the file as environment variables and fill in any other variables in
   the file that don't have defaults. 
1. `terraform init`.
1. `terraform plan`.
1. If the plan looks good, run `terraform apply`.

When the templates are applied, Terraform will output the IP address of the instance 
and the instance path for [connecting using the Cloud SQL Proxy](https://cloud.google.com/sql/docs/postgres/sql-proxy).

Note that you cannot connect to the private IP instance from outside Google Cloud Platform. 
If you want to experiment with connecting from your own workstation, see the [public IP example](https://github.com/gruntwork-io/terraform-google-sql/tree/master/examples/postgres-public-ip)  
