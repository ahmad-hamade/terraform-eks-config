terraform {
  required_version = ">= 0.12.0"
  required_providers {
    aws        = ">= 2.70"
    kubernetes = ">= 1.11"
    helm       = ">= 2.0"
  }
}
