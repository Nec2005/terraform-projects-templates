terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      #version = ">= 3.63"
      version = ">= 4.65"      
     }
  }

}

# Terraform Provider Block
provider "aws" {
  region = "eu-west-2"
  profile = "terraform"
}



resource "aws_s3_bucket" "aws_s3_tfstate" {
  bucket = "ncti-terraform-statefile-dev"
  
}

resource "aws_s3_bucket_acl" "aws_s3_tfstate_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.aws_s3_tfstate_ownership]
  bucket = aws_s3_bucket.aws_s3_tfstate.id
  acl    = "private"
}

resource "aws_s3_bucket_ownership_controls" "aws_s3_tfstate_ownership" {
  bucket = aws_s3_bucket.aws_s3_tfstate.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_versioning" "versioning_aws_s3_tfstate" {
  bucket = aws_s3_bucket.aws_s3_tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "dev-terraform-statefile-lock" {
  count = length(local.list_of_proj)
  name           = "terraform-statefile-lock-${local.list_of_proj[count.index]}"
  hash_key       = "LockID"
  read_capacity  = 5
  write_capacity = 5

  attribute {
    name = "LockID"
    type = "S"
  }
}

