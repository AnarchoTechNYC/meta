output "testvm_private_key" {
  description = "Private SSH key to use to log in to the new VM with."
  value       = tls_private_key.testvm_key.private_key_pem
  sensitive   = true
}

output "testvm_public_key" {
  description = "Public SSH key part."
  value       = tls_private_key.testvm_key.public_key_openssh
}
