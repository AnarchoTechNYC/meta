# Pools are technically optional but there's a bug in the Proxmox VE
# Provider that means we actually have to use them for now.
# See: https://github.com/danitso/terraform-provider-proxmox/issues/41
resource "proxmox_virtual_environment_pool" "test_pool" {
  comment = "Managed by Terraform."
  pool_id = "test_pool"
}
