# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased](https://github.com/ahmad-hamade/terraform-eks-config/compare/v3.1.0...master)

<!--CHANGELOG: Please add all relevant changes here, making sure your change is on top of others. -->
<!--CHANGELOG: DO NOT REMOVE OTHER ENTRIES! -->
<!--CHANGELOG: When releasing, the release engineer will validate your PR and update the version number accordingly. -->
<!--CHANGELOG: For more information please read https://keepachangelog.com/en/1.0.0/ -->

## [v3.1.0](https://github.com/ahmad-hamade/terraform-eks-config/compare/v3.0.0...v3.1.0) - (2020 December 26)

* Rename submodule `eks-iam-role` to `eks-iam-role-with-oidc`
* Add required terraform and providers versions in submodul `eks-iam-role`
* Add README file to `eks-iam-role` submodul
* Remove the default tag key `ManagedBy` from the module

## [v3.0.0](https://github.com/ahmad-hamade/terraform-eks-config/compare/v2.0.0...v3.0.0) - (2020 December 24)

* Removed `aws-auth-config` and `newrelic` services
* Update `cluster-autoscaler` chart repo
* Migrate `stable` and `incubator` helm repos to a new repo
* Migrate `node-problem-detector` to new chart repo
* Removed `load_config_file` from helm provider
* Removed unused tags from IAM roles
* Fixed `code-check` workflow

## [v2.0.0](https://github.com/ahmad-hamade/terraform-eks-config/compare/v1.1.0...v2.0.0) - (2020 October 18)

* Publishing the repo in terraform modules registry

## [v1.1.0](https://github.com/ahmad-hamade/terraform-eks-config/compare/v1.0.0...v1.1.0) - (2020 October 18)

* Enfore running `aws_node_termination_handler` in all EC2 instances
* Set the correct region name in `aws_vpc_cni` for the init image
* Migrate `cluster-autoscaler` helm chart from the old `charts_stable_repo`
* Disable Elasticsearch plugin by default in `aws_fluent_bit`
* Use `set_sensitive` in `newrelic` for the license key variable
* Updated `README.md` file with recent charts versions

## v1.0.0 - (2020 September 3)

* Initial release
