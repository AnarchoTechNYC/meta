terraform {
  required_version = ">= 0.13"
  required_providers {
    proxmox = {
      source  = "localhost.localdomain/danitso/proxmox"
      version = "0.3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 2.2.0"
    }
  }
}
