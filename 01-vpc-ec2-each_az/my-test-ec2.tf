data "aws_ami" "awslinux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # amazon
}


resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = local.var.key_name
  public_key = tls_private_key.example.public_key_openssh

  provisioner "local-exec" { # Create "myKey.pem" to your computer!!
    command = "echo '${tls_private_key.example.private_key_pem}' > ./developer2.pem"
  }

}

module "ec2_instances" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "4.3.0"
  count = length(aws_subnet.private[*])
  #count = 1

  #name = "my-ec2-${count.index}"
  name = "${local.var.node_groups[0].name}-${count.index}"
  key_name      = aws_key_pair.generated_key.key_name
  ami           = data.aws_ami.awslinux.id
  #ami                    = "ami-06ce6bb40e50efe77"
  instance_type          = local.var.node_groups[0].instance_type
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  subnet_id              = aws_subnet.private[count.index].id
  tags = {
    Projzone = "my-${data.aws_availability_zones.current_region.names[count.index]}"
      }

}
