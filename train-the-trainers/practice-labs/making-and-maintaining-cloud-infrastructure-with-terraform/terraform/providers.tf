provider "proxmox" {
  virtual_environment {
    # Uncomment to use the single-node cluster.
    endpoint = "https://192.168.60.2:8006"

    # Uncomment to use the multi-node cluster.
    #endpoint = "https://XXX.XXX.XXX.XXX:8006" # This IP is not yet implemented.

    # Remember to set stronger passwords in a real environment.
    username = "root@pam" # Or set `PROXMOX_VE_USERNAME` environment variable.
    password = "vagrant"  # Or set `PROXMOX_VE_PASSWORD` environment variable.
    insecure = true       # Don't error on TLS cert validation issues.
  }
}
