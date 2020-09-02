data "aws_iam_role" "aws_auth_admins" {
  count = var.aws_auth != null ? length(var.aws_auth.admin_iam_roles) : 0
  name  = var.aws_auth.admin_iam_roles[count.index]
}

data "template_file" "aws_auth_nodes" {
  count    = var.aws_auth != null ? 1 : 0
  template = file("./templates/aws-auth-nodes.tpl")

  vars = {
    nodes_role_arn   = var.aws_auth.nodes_role_arn
    cluster_role_arn = data.aws_eks_cluster.cluster.role_arn
  }
}

data "template_file" "aws_auth_groups" {
  count    = var.aws_auth != null ? length(data.aws_iam_role.aws_auth_admins) : 0
  template = file("./templates/aws-auth-groups.tpl")

  vars = {
    iam_role_arn = data.aws_iam_role.aws_auth_admins[count.index].arn
  }
}

resource "kubernetes_config_map" "aws_auth" {
  count = var.aws_auth != null ? 1 : 0
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    "mapRoles" = join("", data.template_file.aws_auth_nodes.*.rendered, data.template_file.aws_auth_groups.*.rendered)
  }
}
