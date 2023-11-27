data "aws_availability_zones" "current_region" {
  state = "available"
}

resource "tls_private_key" "k8s_nodes_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "aws_key_pair" "k8s_nodes_generated_key" {
  key_name   = local.names.key_name
  public_key = tls_private_key.k8s_nodes_private_key.public_key_openssh

  provisioner "local-exec" { # Create "myKey.pem" to your computer!!
    command = "echo '${tls_private_key.k8s_nodes_private_key.private_key_pem}' > ./${local.names.key_name}.pem"
  }

}
