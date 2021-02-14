resource "proxmox_virtual_environment_pool" "test_pool" {
  comment = "Managed by Terraform."
  pool_id = "test_pool"
}
