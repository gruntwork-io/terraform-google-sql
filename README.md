[![Maintained by Gruntwork.io](https://img.shields.io/badge/maintained%20by-gruntwork.io-%235849a6.svg)](https://gruntwork.io/?ref=repo_google_cloudsql)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/gruntwork-io/terraform-google-sql.svg?label=latest)](http://github.com/gruntwork-io/terraform-google-sql/releases/latest)

# Cloud SQL Modules

<!-- NOTE: We use absolute linking here instead of relative linking, because the terraform registry does not support
           relative linking correctly.
-->

This repo contains modules for running relational databases such as MySQL and PostgreSQL on
[Google Cloud Platform (GCP)](https://cloud.google.com/) using [Cloud SQL](https://cloud.google.com/sql/).

## Quickstart

If you want to quickly spin up a Cloud SQL database, you can run the example that is in the root of this repo. Check out
[postgres-private-ip example documentation](https://github.com/gruntwork-io/terraform-google-sql/blob/master/examples/postgres-private-ip)
for instructions.

## What's in this repo

This repo has the following folder structure:

* [root](https://github.com/gruntwork-io/terraform-google-sql/tree/master): The root folder contains an example of how
  to deploy a private PostgreSQL instance in Cloud SQL. See [postgres-private-ip](https://github.com/gruntwork-io/terraform-google-sql/blob/master/examples/postgres-private-ip)
  for the documentation.

* [modules](https://github.com/gruntwork-io/terraform-google-sql/tree/master/modules): This folder contains the
  main implementation code for this Module, broken down into multiple standalone submodules.

  The primary module is:

    * [cloud-sql](https://github.com/gruntwork-io/terraform-google-sql/tree/master/modules/cloud-sql): Deploy a Cloud SQL [MySQL](https://cloud.google.com/sql/docs/mysql/) or
    [PostgreSQL](https://cloud.google.com/sql/docs/postgres/) database.

* [examples](https://github.com/gruntwork-io/terraform-google-sql/tree/master/examples): This folder contains
  examples of how to use the submodules.

* [test](https://github.com/gruntwork-io/terraform-google-sql/tree/master/test): Automated tests for the submodules
  and examples.

## What is Cloud SQL?

Cloud SQL is Google's fully-managed database service that makes it easy to set up, maintain, manage, and administer 
your relational databases on Google Cloud Platform. Cloud SQL automatically includes: 

* Data replication between multiple zones with automatic failover.
* Automated and on-demand backups, and point-in-time recovery.
* Data encryption on networks, database tables, temporary files, and backups.
* Secure external connections with the [Cloud SQL Proxy](https://cloud.google.com/sql/docs/mysql/sql-proxy) or with the SSL/TLS protocol.

You can learn more about Cloud SQL from [the official documentation](https://cloud.google.com/sql/docs/).

## What's a Module?

A Module is a canonical, reusable, best-practices definition for how to run a single piece of infrastructure, such
as a database or server cluster. Each Module is written using a combination of [Terraform](https://www.terraform.io/)
and scripts (mostly bash) and include automated tests, documentation, and examples. It is maintained both by the open
source community and companies that provide commercial support.

Instead of figuring out the details of how to run a piece of infrastructure from scratch, you can reuse
existing code that has been proven in production. And instead of maintaining all that infrastructure code yourself,
you can leverage the work of the Module community to pick up infrastructure improvements through
a version number bump.

## Who maintains this Module?

This Module and its Submodules are maintained by [Gruntwork](http://www.gruntwork.io/). Read the [Gruntwork Philosophy](https://github.com/gruntwork-io/terraform-google-sql/blob/master/GRUNTWORK_PHILOSOPHY.md) document to learn more about how Gruntwork builds production grade infrastructure code. If you are looking for help or
commercial support, send an email to
[support@gruntwork.io](mailto:support@gruntwork.io?Subject=Google%20SQL%20Module).

Gruntwork can help with:

* Setup, customization, and support for this Module.
* Modules and submodules for other types of infrastructure, such as VPCs, Docker clusters, databases, and continuous
  integration.
* Modules and Submodules that meet compliance requirements, such as HIPAA.
* Consulting & Training on GCP, AWS, Terraform, and DevOps.


## How do I contribute to this Module?

Contributions are very welcome! Check out the [Contribution Guidelines](https://github.com/gruntwork-io/terraform-google-sql/blob/master/CONTRIBUTING.md) for instructions.


## How is this Module versioned?

This Module follows the principles of [Semantic Versioning](http://semver.org/). You can find each new release, along
with the changelog, in the [Releases Page](https://github.com/gruntwork-io/terraform-google-sql/releases).

During initial development, the major version will be 0 (e.g., `0.x.y`), which indicates the code does not yet have a
stable API. Once we hit `1.0.0`, we will make every effort to maintain a backwards compatible API and use the MAJOR,
MINOR, and PATCH versions on each release to indicate any incompatibilities.


## License

Please see [LICENSE](https://github.com/gruntwork-io/terraform-google-sql/blob/master/LICENSE.txt) for how the code in this repo is licensed.

Copyright &copy; 2019 Gruntwork, Inc.
