# Cloud SQL Module

[![Maintained by Gruntwork.io](https://img.shields.io/badge/maintained%20by-gruntwork.io-%235849a6.svg)](https://gruntwork.io/?ref=repo_google_cloudsql)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/gruntwork-io/terraform-google-sql.svg?label=latest)](http://github.com/gruntwork-io/terraform-google-sql/releases/latest)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D0.12.0-blue.svg)


<!-- NOTE: We use absolute linking here instead of relative linking, because the terraform registry does not support
           relative linking correctly.
-->

This module creates a [Google Cloud SQL](https://cloud.google.com/sql/) cluster. 
The cluster is managed by Google, automating backups, replication, patches, and updates. 

This module helps you run [MySQL](https://cloud.google.com/sql/docs/mysql/) and [PostgreSQL](https://cloud.google.com/sql/docs/postgres/) databases in [Google Cloud](https://cloud.google.com/).

## Cloud SQL Architecture

![Cloud SQL Architecture](https://github.com/gruntwork-io/terraform-google-sql/blob/master/_docs/cloud-sql.png "Cloud SQL Architecture")

## Features

- Deploy a fully-managed relational database
- Supports MySQL and PostgreSQL
- Optional failover instances
- Optional read replicas

## Learn

This repo is a part of [the Gruntwork Infrastructure as Code Library](https://gruntwork.io/infrastructure-as-code-library/), a collection of reusable, battle-tested, production ready infrastructure code. If you’ve never used the Infrastructure as Code Library before, make sure to read [How to use the Gruntwork Infrastructure as Code Library](https://gruntwork.io/guides/foundations/how-to-use-gruntwork-infrastructure-as-code-library/)!

### Core concepts

- [What is Cloud SQL](https://github.com/gruntwork-io/terraform-google-sql/blob/master/modules/cloud-sql/core-concepts.md#what-is-cloud-sql)
- [Cloud SQL documentation](https://cloud.google.com/sql/docs/)
- **[Designing Data Intensive Applications](https://dataintensive.net/)**: the best book we’ve found for understanding data systems, including relational databases, NoSQL, replication, sharding, consistency, and so on.

### Repo organisation

This repo has the following folder structure:

- [root](https://github.com/gruntwork-io/terraform-google-sql/tree/master): The root folder contains an example of how
  to deploy a private PostgreSQL instance in Cloud SQL. See [postgres-private-ip](https://github.com/gruntwork-io/terraform-google-sql/blob/master/examples/postgres-private-ip)
  for the documentation.

- [modules](https://github.com/gruntwork-io/terraform-google-sql/tree/master/modules): This folder contains the
  main implementation code for this Module, broken down into multiple standalone submodules.

  The primary module is:

  - [cloud-sql](https://github.com/gruntwork-io/terraform-google-sql/tree/master/modules/cloud-sql): Deploy a Cloud SQL [MySQL](https://cloud.google.com/sql/docs/mysql/) or [PostgreSQL](https://cloud.google.com/sql/docs/postgres/) database.
  
- [examples](https://github.com/gruntwork-io/terraform-google-sql/tree/master/examples): This folder contains
  examples of how to use the submodules.

- [test](https://github.com/gruntwork-io/terraform-google-sql/tree/master/test): Automated tests for the submodules
  and examples.

## Deploy

### Non-production deployment (quick start for learning)

If you just want to try this repo out for experimenting and learning, check out the following resources:

- [examples folder](https://github.com/gruntwork-io/terraform-google-sql/blob/master/examples): The `examples` folder contains sample code optimized for learning, experimenting, and testing (but not production usage).

### Production deployment

If you want to deploy this repo in production, check out the following resources:

- [cloud-sql module in the GCP Reference Architecture](https://github.com/gruntwork-io/infrastructure-modules-google/tree/master/data-stores/cloud-sql): 
Production-ready sample code from the GCP Reference Architecture. Note that the repository is private and accessible only with 
Gruntwork subscription. To get access, [subscribe now](https://www.gruntwork.io/pricing/) or contact us at [support@gruntwork.io](mailto:support@gruntwork.io) for more information.

## Manage

### Day-to-day operations

- [How to connect to a Cloud SQL instance](https://github.com/gruntwork-io/terraform-google-sql/tree/master/modules/cloud-sql/core-concepts.md#how-do-you-connect-to-the-database)
- [How to configure high availability](https://github.com/gruntwork-io/terraform-google-sql/tree/master/modules/cloud-sql/core-concepts.md#how-do-you-configure-high-availability)
- [How to secure the database instance](https://github.com/gruntwork-io/terraform-google-sql/tree/master/modules/cloud-sql/core-concepts.md#how-do-you-secure-the-database)
- [How to scale the database](https://github.com/gruntwork-io/terraform-google-sql/tree/master/modules/cloud-sql/core-concepts.md#how-do-you-secure-the-database)

## Known Issues

### Instance Recovery

Due to limitations on the current `terraform` provider for Google, it is not possible to restore backups with `terraform`. 

See https://github.com/terraform-providers/terraform-provider-google/issues/2446

## Support

If you need help with this repo or anything else related to infrastructure or DevOps, Gruntwork offers [Commercial Support](https://gruntwork.io/support/) via Slack, email, and phone/video. If you’re already a Gruntwork customer, hop on Slack and ask away! If not, [subscribe now](https://www.gruntwork.io/pricing/). If you’re not sure, feel free to email us at [support@gruntwork.io](mailto:support@gruntwork.io).

## Contributions

Contributions to this repo are very welcome and appreciated! If you find a bug or want to add a new feature or even contribute an entirely new module, we are very happy to accept pull requests, provide feedback, and run your changes through our automated test suite.

Please see [Contributing to the Gruntwork Infrastructure as Code Library](https://gruntwork.io/guides/foundations/how-to-use-gruntwork-infrastructure-as-code-library/#contributing-to-the-gruntwork-infrastructure-as-code-library) for instructions.

## License

Please see [LICENSE](https://github.com/gruntwork-io/terraform-google-sql/blob/master/LICENSE.txt) for details on how the code in this repo is licensed.

Copyright &copy; 2019 Gruntwork, Inc.
