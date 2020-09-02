# EKS Services

![Terraform](https://img.shields.io/badge/Terraform=>v0.12.0-blue.svg)

## Overview

This module made the following services setup in EKS easier and adjustable:

| Service | Description |
| --- | --- |
| [aws-auth](https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html) | This service will do the EKS Auth setup possible for configuring workers nodes and allowing specific IAM roles to access the cluster |
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
| [newrelic](https://github.com/newrelic/helm-charts/tree/master/charts/nri-bundle) | NewRelic monitoring integration. |
| [external-dns](https://github.com/bitnami/charts/tree/master/bitnami/external-dns) | Automatically provision Route53 records for ingress resources. |
| [aws-efs-csi-driver](https://github.com/Kubernetes-sigs/aws-efs-csi-driver/tree/master/helm) | The Amazon Elastic File System Container Storage Interface (CSI) Driver. |
| [aws-fluent-bit](https://github.com/aws/eks-charts/tree/master/stable/aws-for-fluent-bit) | Log collection that supports shipping to AWS Kinesis, ES and CW. |

> ⚠️ **Note!**
>
> It's recommended always to set a specific chart version for every service and don't use `null` as a value in variable `version` to avoid using the `latest` version that might not be stable or compatible with your EKS cluster.
>

## Dependencies

This module expects an EKS cluster created and its up and running

## Usage

Import the module and retrieve it with `terraform get` .

```terraform
module "eks_config" {
  source = "git::ssh://git@github.com/ahmad-hamade/eks-services.git?ref=TAG"

  cluster_name = var.cluster_name

  aws_auth = {
    nodes_role_arn  = module.eks_control_plane.worker_node_role_arn
    admin_iam_roles = ["Admin", "Developer"]
  }

  # Make sure to delete the existing VPC CNI resources by running the below command before installing this service:
  # kubectl delete -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/release-1.6/config/v1.6/aws-k8s-cni.yaml
  aws_vpc_cni = {
    version    = "1.0.9"
    extra_sets = {
      "image.tag" : "v1.6.3"
    }
  }

  kube2iam = {
    version    = "2.5.1"
    extra_sets = {
      "image.tag" : "0.10.10"
    }
  }

  aws_alb_ingress_controller = {
    version    = "1.0.2"
    extra_sets = {
      "image.tag" : "v1.1.8"
    }
  }

  # Consider installing this service if you only have spot instances running in your cluster
  aws_node_termination_handler = {
    version = "0.9.5"
    extra_sets = {
      "image.tag" : "v1.7.0"
    }
  }

  node_problem_detector = {
    version = "1.7.6"
    extra_sets = {
      "image.tag" : "v0.8.2"
    }
  }

  # This service is required if you want to install twistlock as well
  efs_provisioner = {
    version    = "0.13.0"
    fs_id      = module.efs_endpoints.efs_id
    extra_sets = {
      "image.tag" : "v2.4.0"
    }
  }

  aws_fluent_bit = {
    version             = "0.1.3"
    kinesis_stream_name = module.logging_kinesis.kinesis_stream_name
    extra_sets = {
      "image.tag" : "2.6.1"
    }
  }

  # Install this service in Dev/Test environments if you plan to scale down services after office hours
  kube_downscaler = {
    version = "0.5.0"
    extra_sets = {
      "image.tag" : "20.5.0"
    }
  }

  kube_state_metrics = {
    version = "2.8.14"
    extra_sets = {
      "image.tag" : "v1.9.7"
    }
  }

  external_dns = {
    version          = "3.3.0"
    route53_zone_ids = [module.route53_env.public_domain_zone_id]
    extra_sets = {
      "image.tag" : "0.7.3"
    }
  }

  metrics_server = {
    version = "2.11.1"
    extra_sets = {
      "image.repository" : "k8s.gcr.io/metrics-server/metrics-server"
      "image.tag" : "v0.3.7"
    }
  }

  # Make sure the image.tag is matching your cluster version
  cluster_autoscaler = {
    version = "7.3.4"
    extra_sets = {
      "image.repository" : "k8s.gcr.io/autoscaling/cluster-autoscaler"
      "image.tag" : "v1.17.3"
    }
  }

  newrelic = {
    version     = "1.6.0"
    license_key = module.secret_newrelic_license_key.ssm_parameter_value
    extra_sets  = null
  }
}
```

## Thinking Ahead

I would like to do the following alongside others who want to work with EKS infra services:

- Make aws-auth-config dynamic to accept policy provided by the user
- Add Jenkins service
- Add nginx ingress controller
- Add skipper ingress controller

If anyone wants to pick up any work here, feel free to open a branch; if you want to contact me personally about this

Email: a.hamade@live.com

<!--BEGIN:terraform-docs-->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |
| aws | >= 2.70 |
| helm | >= 1.2 |
| kubernetes | >= 1.11 |
| template | >= 2.1 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.70 |
| helm | >= 1.2 |
| kubernetes | >= 1.11 |
| template | >= 2.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_name | EKS Cluster name to install the services | `string` | n/a | yes |
| aws\_alb\_ingress\_controller | ALB ingress configuration | <pre>object({<br>    version    = string<br>    extra_sets = map(string)<br>  })</pre> | `null` | no |
| aws\_auth | AWS configuration for cluster authentication | <pre>object({<br>    nodes_role_arn  = string<br>    admin_iam_roles = list(string)<br>  })</pre> | `null` | no |
| aws\_efs\_csi\_driver | Amazon Elastic File System Container Storage Interface (CSI) Driver | <pre>object({<br>    version    = string<br>    extra_sets = map(string)<br>  })</pre> | `null` | no |
| aws\_fluent\_bit | AWS Fluentbit | <pre>object({<br>    version             = string<br>    kinesis_stream_name = string<br>    extra_sets          = map(string)<br>  })</pre> | `null` | no |
| aws\_node\_termination\_handler | AWS Node Termination Handler | <pre>object({<br>    version    = string<br>    extra_sets = map(string)<br>  })</pre> | `null` | no |
| aws\_vpc\_cni | Installs the AWS CNI Daemonset | <pre>object({<br>    version    = string<br>    extra_sets = map(string)<br>  })</pre> | `null` | no |
| cluster\_autoscaler | Cluster autoscaler configuration | <pre>object({<br>    version    = string<br>    extra_sets = map(string)<br>  })</pre> | `null` | no |
| efs\_provisioner | EFS Provisioner | <pre>object({<br>    version    = string<br>    fs_id      = string<br>    extra_sets = map(string)<br>  })</pre> | `null` | no |
| external\_dns | Configures public DNS servers with information about exposed Kubernetes services | <pre>object({<br>    version          = string<br>    route53_zone_ids = list(string)<br>    extra_sets       = map(string)<br>  })</pre> | `null` | no |
| kube2iam | kube2iam | <pre>object({<br>    version    = string<br>    extra_sets = map(string)<br>  })</pre> | `null` | no |
| kube\_downscaler | Scale down Kubernetes deployments and/or statefulsets during non-work hours | <pre>object({<br>    version    = string<br>    extra_sets = map(string)<br>  })</pre> | `null` | no |
| kube\_state\_metrics | Kube State Metrics | <pre>object({<br>    version    = string<br>    extra_sets = map(string)<br>  })</pre> | `null` | no |
| metrics\_server | Resource metrics are used by components like kubectl top and the HPA | <pre>object({<br>    version    = string<br>    extra_sets = map(string)<br>  })</pre> | `null` | no |
| newrelic | Newrelic nri-bundle | <pre>object({<br>    version     = string<br>    license_key = string<br>    extra_sets  = map(string)<br>  })</pre> | `null` | no |
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
| newrelic | NewRelic |
| node\_problem\_detector | Nod Problem Detector |

<!--END:terraform-docs-->
