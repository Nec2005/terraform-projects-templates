output "bucket_names" { 
 value = aws_s3_bucket.aws_s3_tfstate[*].id  
}

output "table_names" { 
 value = aws_dynamodb_table.dev-terraform-statefile-lock[*].name
}