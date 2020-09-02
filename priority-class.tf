resource "kubernetes_priority_class" "high_priority_class" {
  metadata {
    name = var.priority_class_mames.high_priority
  }

  value          = 10000000
  global_default = false
  description    = "This is priority class that should be used for cluster essential addons i.e. cluster-autoscaler."
}

resource "kubernetes_priority_class" "medium_priority_class" {
  metadata {
    name = var.priority_class_mames.medium_priority
  }

  value          = 5000000
  global_default = false
  description    = "This is priority class that should be used for important pods."
}

resource "kubernetes_priority_class" "low_priority_class" {
  metadata {
    name = var.priority_class_mames.low_priority
  }

  value          = 1000000
  global_default = false
  description    = "This is priority class that should be used for non essential pods."
}
