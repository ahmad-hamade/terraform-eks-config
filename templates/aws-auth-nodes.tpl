- rolearn: ${nodes_role_arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
- rolearn: ${cluster_role_arn}
  username: user:cluster-admin:{{SessionName}}
  groups:
    - system:masters
