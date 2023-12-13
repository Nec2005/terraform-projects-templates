# Terraform Settings Block
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      #version = "~> 3.70"
      version = ">= 4.65"
    }
    helm = {
      source = "hashicorp/helm"
      #version = "2.4.1"
      #version = "~> 2.4"
      version = "~> 2.9"
    }
    http = {
      source = "hashicorp/http"
      #version = "2.1.0"
      #version = "~> 2.1"
      version = "~> 3.3"
    }
   
  }
  # Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "ncti-terraform-statefile-dev"
    key    = "dev/k8s/terraform.tfstate"
    region = "eu-west-2" 

    # For State Locking
    dynamodb_table = "terraform-statefile-lock-appk8s"    
  }     

}
