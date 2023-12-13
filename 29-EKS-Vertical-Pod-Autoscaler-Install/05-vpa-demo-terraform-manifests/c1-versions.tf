# Terraform Settings Block
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      #version = "~> 4.14"
      version = ">= 4.65"
     }
    kubernetes = {
      source = "hashicorp/kubernetes"
      #version = "~> 2.11"
      version = ">= 2.20"
    }      
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
    }     
  }
  # Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "ncti-terraform-statefile-dev"
    key    = "dev/vpa/terraform.tfstate"
    region = "eu-west-2" 

    # For State Locking
    #dynamodb_table = "dev-vpa-demo-app"    
  }     
}
