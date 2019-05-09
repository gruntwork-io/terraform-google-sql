# Client Certificate Example

This folder contains an example of how to create client certificates for [Cloud SQL](https://cloud.google.com/sql/) database instance. 
There can be only one pending operation at a given point of time because of the inherent Cloud SQL system architecture.
This is a limitation on the concurrent writes to a Cloud SQL database. To resolve this issue,
we will create the certificate in a separate module.

Creating the certificate while there are other operations ongoing will result in `googleapi: Error 409: Operation failed because another operation was already in progress.`


## How do you run this example?

To run this example, you need to:

1. Install [Terraform](https://www.terraform.io/).
1. Open up `variables.tf` and set secrets at the top of the file as environment variables and fill in any other variables in
   the file that don't have defaults. 
1. `terraform init`.
1. `terraform plan`.
1. If the plan looks good, run `terraform apply`.

When the templates are applied, Terraform will output the IP address of the instance and the instance path for [connecting using the Cloud SQL Proxy](https://cloud.google.com/sql/docs/mysql/connect-admin-proxy). 
