# AWS EC2 Instance Terraform Module

# Get latest AMI ID for Amazon Linux2 OS
data "aws_ami" "amzlinux2" {
  most_recent = true
  owners = [ "amazon" ]
  filter {
    name = "name"
    values = [ "amzn2-ami-hvm-*-gp2" ]
  }
  filter {
    name = "root-device-type"
    values = [ "ebs" ]
  }
  filter {
    name = "virtualization-type"
    values = [ "hvm" ]
  }
  filter {
    name = "architecture"
    values = [ "x86_64" ]
  }
}


# Bastion Host - EC2 Instance that will be created in VPC Public Subnet
module "ec2_public" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  #version = "~> 3.0"
  #version = "3.3.0"
  version = "5.0.0"  

  name = "${local.name}-BastionHost"
  ami                    = data.aws_ami.amzlinux2.id
  instance_type          = var.instance_type
  key_name               = var.instance_keypair
  #monitoring             = true
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [module.public_bastion_sg.security_group_id]
  
  tags = local.common_tags
}

# Create Elastic IP for Bastion Host 

# Resource - depends_on Meta-Argument
# resource "aws_eip" "bastion_eip" {
#   depends_on = [module.ec2_public, module.vpc ]
#   instance = module.ec2_public.id
#   domain   = "vpc"
#   tags = local.common_tags  
# }
