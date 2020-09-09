resource "tls_private_key" "testvm_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

