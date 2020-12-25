locals {
  cluster_name = data.aws_eks_cluster.cluster.id

  charts_incubator_repo  = "https://charts.helm.sh/incubator"
  charts_stable_repo     = "https://charts.helm.sh/stable"
  charts_bitnami_repo    = "https://charts.bitnami.com/bitnami"
  charts_aws_repo        = "https://aws.github.io/eks-charts"
  charts_autoscaler_repo = "https://kubernetes.github.io/autoscaler"
}
