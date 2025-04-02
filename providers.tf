terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.50.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.4-alpha.2"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}