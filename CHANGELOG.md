# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased](https://github.com/ahmad-hamade/eks-services/compare/1.0.0...master)

* Enfore running `aws_node_termination_handler` in all EC2 instances
* Set the correct region name in `aws_vpc_cni` for the init image
* Migrate `cluster-autoscaler` helm chart from the old `charts_stable_repo`
* Disable Elasticsearch plugin by default in `aws_fluent_bit`
* Use `set_sensitive` in `newrelic` for the license key variable
* Updated `README.md` file with recent charts versions

<!--CHANGELOG: Please add all relevant changes here, making sure your change is on top of others. -->
<!--CHANGELOG: DO NOT REMOVE OTHER ENTRIES! -->
<!--CHANGELOG: When releasing, the release engineer will validate your PR and update the version number accordingly. -->
<!--CHANGELOG: For more information please read https://keepachangelog.com/en/1.0.0/ -->

## 1.0.0 - (2020 September 3)

* Initial release
