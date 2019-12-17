<!--
:type: service
:name: MySQL
:description: Deploy and manage MySQL on GCP using Google's Cloud SQL Service
:icon: /_docs/mysql.png
:category: database
:cloud: gcp
:tags: data, database, sql, mysql
:license: open-source
:built-with: terraform
-->
# MySQL
[![Maintained by Gruntwork.io](https://img.shields.io/badge/maintained%20by-gruntwork.io-%235849a6.svg)](https://gruntwork.io/?ref=repo_google_cloudsql)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/gruntwork-io/terraform-google-sql.svg?label=latest)](http://github.com/gruntwork-io/terraform-google-sql/releases/latest)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D0.12.0-blue.svg)

This module deploys MySQL on top of Google's Cloud SQL Service. The cluster is managed by GCP and automatically handles 
standby failover, read replicas, backups, patching, and encryption.

[README.md](./README.md)
