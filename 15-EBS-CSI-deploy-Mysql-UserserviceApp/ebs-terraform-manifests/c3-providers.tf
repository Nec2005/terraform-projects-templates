# Terraform AWS Provider Block
provider "aws" {
  region = "eu-west-2"
  profile = "terraform"

}

# Terraform Remote State Datasource
data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "ncti-terraform-statefile-dev"
    key    = "dev/eks-cluster/terraform.tfstate"
    region = var.aws_region
  }   
}



# Terraform HTTP Provider Block
provider "http" {
  # Configuration options
}