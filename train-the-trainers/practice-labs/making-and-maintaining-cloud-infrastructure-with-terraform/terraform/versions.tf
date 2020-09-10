terraform {
  required_version = ">= 0.13"
  required_providers {
    proxmox = {
      source  = "localhost.localdomain/danitso/proxmox"
      version = ">= 0.3.0"
    }
  }
}
