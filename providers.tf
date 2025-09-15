terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.52.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.4"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}