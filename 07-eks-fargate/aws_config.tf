# aws_config.tf | Main Configuration

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }

  # backend "s3" {
  #   # S3 Bucket Configs
  #   bucket  = "nbs-devops-interviews-terraform"
  #   key     = "necati/terraform.tfstate"
  #   region  = "eu-west-1"

  # }
}

provider "aws" {
    region = var.region
    profile = var.aws_profile
    
    default_tags {
        tags = {
            AppName = var.app_name
            Environment = var.app_env
        }
    }
}

