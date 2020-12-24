# EKS Services

![Code Check](https://github.com/ahmad-hamade/terraform-eks-config/workflows/code-check/badge.svg)
![Security Check](https://github.com/ahmad-hamade/terraform-eks-config/workflows/security-check/badge.svg)
![Terraform](https://img.shields.io/badge/Terraform->=v0.12.6-blue.svg)
![Latest Release](https://img.shields.io/github/release/ahmad-hamade/terraform-eks-config.svg)

- [EKS Services](#eks-services)
  - [Overview](#overview)
  - [Compatibility](#compatibility)
  - [Dependencies](#dependencies)
  - [Usage](#usage)
  - [Deprecated services](#deprecated-services)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Inputs](#inputs)
  - [Outputs](#outputs)
  - [Authors](#authors)
  - [License](#license)

## Overview

This module made the following services setup in EKS easier and adjustable:

| Service | Description |
| --- | --- |
| [aws-vpc-cni](https://github.com/aws/eks-charts/tree/master/stable/aws-vpc-cni) | Networking plugin for pod networking in Kubernetes using Elastic Network Interfaces on AWS. |
| [kube-downscaler](https://github.com/helm/charts/tree/master/incubator/kube-downscaler) | Scale down Kubernetes Deployments, StatefulSets, and/or HorizontalPodAutoscalers during non-work hours. |
| [cluster-autoscaler](https://github.com/helm/charts/tree/master/stable/cluster-autoscaler) | Cluster Autoscaler is a tool that automatically adjusts the size of the Kubernetes cluster. |
| [node-problem-detector](https://github.com/helm/charts/tree/master/stable/node-problem-detector) | Make various node problems visible to the upstream layers in cluster management stack. |
| [kube2iam](https://github.com/helm/charts/tree/master/stable/kube2iam) | Provide IAM credentials to containers running inside a Kubernetes cluster based on annotations. |
| [aws-alb-ingress-controller](https://github.com/helm/charts/tree/master/incubator/aws-alb-ingress-controller) | The AWS ALB Ingress Controller satisfies Kubernetes ingress resources by provisioning Application Load Balancers. |
| [metrics-server](https://github.com/helm/charts/tree/master/stable/metrics-server) | Metrics Server is a scalable, efficient source of container resource metrics for Kubernetes built-in autoscaling pipelines. |
| [kube-state-metrics](https://github.com/helm/charts/tree/master/stable/kube-state-metrics) | kube-state-metrics is about generating metrics from Kubernetes API objects without modification. |
| [node-termination-handler](https://github.com/aws/eks-charts/tree/master/stable/aws-node-termination-handler) | Safely handle node terminations (e.g. spot instance being reclaimed) by automatically draining the node first. |
| [efs-provisioner](https://github.com/helm/charts/tree/master/stable/efs-provisioner) | Cross-AZ persistent storage with support for attaching to multiple pods.| Somewhat slower speeds than using EBS but not usually noticeable unless working with disk-intensive applications. |
| [external-dns](https://github.com/bitnami/charts/tree/master/bitnami/external-dns) | Automatically provision Route53 records for ingress resources. |
| [aws-efs-csi-driver](https://github.com/Kubernetes-sigs/aws-efs-csi-driver/tree/master/helm) | The Amazon Elastic File System Container Storage Interface (CSI) Driver. |
| [aws-fluent-bit](https://github.com/aws/eks-charts/tree/master/stable/aws-for-fluent-bit) | Log collection that supports shipping to AWS Kinesis, ES and CW. |

> ⚠️ **Note!**
>
> It's recommended always to set a specific chart version for every service and don't use `null` as a value in variable `version` to avoid using the `latest` version that might not be stable or compatible with your EKS cluster.
>

## Compatibility

This module can be used with Terraform `0.12.x` and `0.13.x`.

All examples mentioned in the usage section are tested with Kubernetes EKS 1.17.

## Dependencies

This module expects an EKS cluster created and its up and running.

## Usage

Import the module and retrieve it with `terraform get`:

```terraform
module "eks_config" {
  source = "git@github.com:ahmad-hamade/terraform-eks-config.git//.?ref=TAG"

  cluster_name = module.eks_control_plane.tags_map["ClusterName"]

  # Make sure to delete the existing VPC CNI resources by running the below command before installing this service:
  # kubectl delete -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/release-1.6/config/v1.6/aws-k8s-cni.yaml
  aws_vpc_cni = {
    version    = "1.1.1"
    extra_sets = {
      "init.image.tag" : "v1.7.5"
      "image.tag" : "v1.7.5"
    }
  }

  aws_alb_ingress_controller = {
    version    = "1.0.4"
    extra_sets = {
      "image.tag" : "v1.1.8"
    }
  }

  aws_node_termination_handler = {
    version = "0.13.2"
    extra_sets = {
      "image.tag" : "v1.11.2"
    }
  }

  node_problem_detector = {
    version = "1.8.3"
    extra_sets = {
      "image.repository" : "k8s.gcr.io/node-problem-detector/node-problem-detector"
      "image.tag" : "v0.8.5"
    }
  }

  aws_efs_csi_driver = {
    version = "0.1.0"
    extra_sets = {
      "image.tag" : "v1.0.0"
    }
  }

  aws_fluent_bit = {
    version             = "0.1.5"
    kinesis_stream_name = module.logging_kinesis.kinesis_stream_name
    extra_sets = {
      "image.tag" : "2.10.0"
    }
  }

  # Install this service in Dev/Test environments if you plan to scale down services after office hours
  kube_downscaler = {
    version = "0.6.2"
    extra_sets = {
      "image.tag" : "20.10.0"
    }
  }

  kube_state_metrics = {
    version = "2.9.4"
    extra_sets = {
      "image.tag" : "v1.9.7"
    }
  }

  external_dns = {
    version          = "4.0.0"
    route53_zone_ids = [module.route53_env.public_domain_zone_id]
    extra_sets = {
      "image.tag" : "0.7.4"
    }
  }

  metrics_server = {
    version = "2.11.4"
    extra_sets = {
      "image.repository" : "k8s.gcr.io/metrics-server/metrics-server"
      "image.tag" : "v0.4.1"
    }
  }

  cluster_autoscaler = {
    version = "9.3.0"
    extra_sets = {
      "image.repository" : "k8s.gcr.io/autoscaling/cluster-autoscaler"
      "image.tag" : "v1.17.3"
    }
  }

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
```

## Deprecated services

The below example is using deprecated services `kube2iam` and `efs-provisioner` which will be deleted in feature releases:

```terraform
kube2iam = {
  version    = "2.5.1"
  extra_sets = {
    "image.tag" : "0.10.11"
  }
}

efs_provisioner = {
  version    = "0.13.0"
  fs_id      = module.efs_endpoints.efs_id
  extra_sets = {
    "image.tag" : "v2.4.0"
  }
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.0 |
| aws | >= 2.70 |
| helm | >= 2.0 |
| kubernetes | >= 1.11 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.70 |
| helm | >= 2.0 |
| kubernetes | >= 1.11 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws\_alb\_ingress\_controller | ALB ingress configuration | <pre>object({<br>    version    = string<br>    extra_sets = map(string)<br>  })</pre> | `null` | no |
| aws\_efs\_csi\_driver | Amazon Elastic File System Container Storage Interface (CSI) Driver | <pre>object({<br>    version    = string<br>    extra_sets = map(string)<br>  })</pre> | `null` | no |
| aws\_fluent\_bit | AWS Fluentbit | <pre>object({<br>    version             = string<br>    kinesis_stream_name = string<br>    extra_sets          = map(string)<br>  })</pre> | `null` | no |
| aws\_node\_termination\_handler | AWS Node Termination Handler | <pre>object({<br>    version    = string<br>    extra_sets = map(string)<br>  })</pre> | `null` | no |
| aws\_vpc\_cni | Installs the AWS CNI Daemonset | <pre>object({<br>    version    = string<br>    extra_sets = map(string)<br>  })</pre> | `null` | no |
| cluster\_autoscaler | Cluster autoscaler configuration | <pre>object({<br>    version    = string<br>    extra_sets = map(string)<br>  })</pre> | `null` | no |
| cluster\_name | EKS Cluster name to install the services | `string` | n/a | yes |
| efs\_provisioner | EFS Provisioner | <pre>object({<br>    version    = string<br>    fs_id      = string<br>    extra_sets = map(string)<br>  })</pre> | `null` | no |
| external\_dns | Configures public DNS servers with information about exposed Kubernetes services | <pre>object({<br>    version          = string<br>    route53_zone_ids = list(string)<br>    extra_sets       = map(string)<br>  })</pre> | `null` | no |
| kube2iam | kube2iam | <pre>object({<br>    version    = string<br>    extra_sets = map(string)<br>  })</pre> | `null` | no |
| kube\_downscaler | Scale down Kubernetes deployments and/or statefulsets during non-work hours | <pre>object({<br>    version    = string<br>    extra_sets = map(string)<br>  })</pre> | `null` | no |
| kube\_state\_metrics | Kube State Metrics | <pre>object({<br>    version    = string<br>    extra_sets = map(string)<br>  })</pre> | `null` | no |
| metrics\_server | Resource metrics are used by components like kubectl top and the HPA | <pre>object({<br>    version    = string<br>    extra_sets = map(string)<br>  })</pre> | `null` | no |
| node\_problem\_detector | Make various node problems visible to the upstream layers in cluster management stack | <pre>object({<br>    version    = string<br>    extra_sets = map(string)<br>  })</pre> | `null` | no |
| priority\_class\_mames | The name of default priority class to be created in the EKS cluster | <pre>object({<br>    high_priority   = string<br>    medium_priority = string<br>    low_priority    = string<br>  })</pre> | <pre>{<br>  "high_priority": "high-priority",<br>  "low_priority": "low-priority",<br>  "medium_priority": "medium-priority"<br>}</pre> | no |
| tags | Additional tags to be applied to all resources created for the AWS resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| aws\_alb\_ingress\_controller | AWS ALB Ingress Controller |
| aws\_efs\_csi\_driver | AWS EFS CSI Driver |
| aws\_fluent\_bit | AWS Fluent-bit |
| aws\_node\_termination\_handler | AWS Node Termination Handler |
| aws\_vpc\_cni | AWS VPC CNI |
| cluster\_autoscaler | Cluster autoscaler |
| efs\_provisioner | EFS Provisioner |
| external\_dns | External DNS |
| kube2iam | Kube2IAM |
| kube\_downscaler | Kube Downscaler |
| kube\_state\_metrics | Kube State Metrics |
| metrics\_server | Metrics Server |
| node\_problem\_detector | Nod Problem Detector |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

This module is maintained by [Ahmad Hamade](https://github.com/ahmad-hamade) with help from [these awesome contributors](https://github.com/ahmad-hamade/terraform-eks-config/graphs/contributors).

## License

Apache 2 Licensed. See LICENSE for full details.
