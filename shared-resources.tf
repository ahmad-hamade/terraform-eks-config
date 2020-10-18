locals {
  cluster_name = data.aws_eks_cluster.cluster.id

  charts_incubator_repo  = "http://storage.googleapis.com/kubernetes-charts-incubator"
  charts_stable_repo     = "https://kubernetes-charts.storage.googleapis.com"
  charts_newrelic_repo   = "https://helm-charts.newrelic.com"
  charts_bitnami_repo    = "https://charts.bitnami.com/bitnami"
  charts_aws_repo        = "https://aws.github.io/eks-charts"
  charts_autoscaler_repo = "https://kubernetes.github.io/autoscaler"

  tags_map = merge(
    {
      ManagedBy = "EKS-Config-Module:1.1.0"
    },
    var.extra_tags,
  )
}

data "aws_region" "current" {}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster_auth" {
  name = local.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster_auth.token
  load_config_file       = false
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster_auth.token
    load_config_file       = false
  }
}
