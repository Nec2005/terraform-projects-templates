# Terraform Settings Block
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      #version = ">= 3.63"
      version = ">= 4.65"      
     }
  }
  # Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "ncti-terraform-statefile-dev"
    key    = "dev/eks-cluster/terraform.tfstate"
    region = "eu-west-2" 

    # For State Locking
    #dynamodb_table = "terraform-statefile-lock-eks"    
  }     

}

# Terraform Provider Block
provider "aws" {
  region = var.aws_region
  profile = "terraform"
}



