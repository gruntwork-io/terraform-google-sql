[![Maintained by Gruntwork.io](https://img.shields.io/badge/maintained%20by-gruntwork.io-%235849a6.svg)](https://gruntwork.io/?ref=repo_google_cloudsql)

# Cloud SQL Modules

This repo contains modules for running relational databases such as MySQL and PostgreSQL on Google's
[Cloud SQL](https://cloud.google.com/sql/) on [GCP](https://cloud.google.com/).

## Code included in this Module

* [cloud-sql](/modules/cloud-sql): Deploy a Cloud SQL cluster.


## What is Cloud SQL?

Cloud SQL is Google's fully-managed database service that makes it easy to set up, maintain, manage, and administer 
your relational databases on Google Cloud Platform. Cloud SQL automatically includes Data replication between multiple 
zones with automatic failover, automated and on-demand backups, and point-in-time recovery.

You can learn more Cloud SQL from [the official documentation](https://cloud.google.com/sql/docs/).

## Who maintains this Module?

This Module and its Submodules are maintained by [Gruntwork](http://www.gruntwork.io/). If you are looking for help or
commercial support, send an email to
[support@gruntwork.io](mailto:support@gruntwork.io?Subject=Google%20SQL%20Module).

Gruntwork can help with:

* Setup, customization, and support for this Module.
* Modules and submodules for other types of infrastructure, such as VPCs, Docker clusters, databases, and continuous
  integration.
* Modules and Submodules that meet compliance requirements, such as HIPAA.
* Consulting & Training on GCP, AWS, Terraform, and DevOps.


## How do I contribute to this Module?

Contributions are very welcome! Check out the [Contribution Guidelines](/CONTRIBUTING.md) for instructions.


## How is this Module versioned?

This Module follows the principles of [Semantic Versioning](http://semver.org/). You can find each new release, along
with the changelog, in the [Releases Page](../../releases).

During initial development, the major version will be 0 (e.g., `0.x.y`), which indicates the code does not yet have a
stable API. Once we hit `1.0.0`, we will make every effort to maintain a backwards compatible API and use the MAJOR,
MINOR, and PATCH versions on each release to indicate any incompatibilities.


## License

Please see [LICENSE.txt](/LICENSE.txt) for details on how the code in this repo is licensed.
