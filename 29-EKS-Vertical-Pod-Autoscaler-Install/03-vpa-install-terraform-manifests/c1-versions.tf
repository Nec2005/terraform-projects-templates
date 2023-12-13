# Terraform Settings Block
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    null = {
      source = "hashicorp/null"
      version = "~> 3.1"
    }
  }
  # Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "ncti-terraform-statefile-dev"
    key    = "dev/eks-vpa/terraform.tfstate"
    region = "eu-west-2" 

    # For State Locking
    #dynamodb_table = "dev-eks-vpa-install"    
  }     
}

provider "null" {
  # Configuration options
}