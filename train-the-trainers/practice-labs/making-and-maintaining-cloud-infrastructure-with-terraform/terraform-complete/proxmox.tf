data "proxmox_virtual_environment_nodes" "pve_nodes" {}

resource "proxmox_virtual_environment_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = data.proxmox_virtual_environment_nodes.pve_nodes.names[0]

  source_file {
    path = "https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img"
  }
}

resource "proxmox_virtual_environment_vm" "testvm" {
  node_name = data.proxmox_virtual_environment_nodes.pve_nodes.names[0]
  pool_id = proxmox_virtual_environment_pool.test_pool.id

  # These two arguments are marked "optional" in the Provider docs,
  # but several bugs crop up if we don't include them. See:
  #
  #     https://github.com/danitso/terraform-provider-proxmox/issues/42
  #     https://github.com/danitso/terraform-provider-proxmox/issues/43
  #
  name = "testvm"
  #vm_id   = 105 # This must be unique, so it'd make a good Terraform Module.

  disk {
    file_id   = proxmox_virtual_environment_file.ubuntu_cloud_image.id
    interface = "scsi0"
    #size      = 3 # Three gigabytes.
  }

  # Attach a NIC and a serial device with default settings.
  # These are both required for Cloud-Init support. See:
  #     https://pve.proxmox.com/wiki/Cloud-Init_Support
  network_device {} # This will be bridged to interface `vmbr0`.
  serial_device {}

  # Add a second NIC with a statically-configured IP address.
  network_device {
    bridge = "vmbr1"
  }

  # We have to supply some basic Cloud-Init parameters so cloud-init
  # knows what to do with itself.
  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    ip_config {
      ipv4 {
        address = "10.10.10.50/24"
      }
    }
    user_account {
      username = "ubuntu"
      password = "ubuntu"
      # Keys are preferred over `password`, for obvious reasons.
      keys = [
        trimspace(tls_private_key.testvm_key.public_key_openssh),
      ]
    }
  }
}
