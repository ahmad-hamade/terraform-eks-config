terraform {
  required_version = ">= 0.12.0, < 0.14.0"
  required_providers {
    aws        = ">= 2.70"
    template   = ">= 2.1"
    kubernetes = ">= 1.11"
    helm       = ">= 1.2"
  }
}
