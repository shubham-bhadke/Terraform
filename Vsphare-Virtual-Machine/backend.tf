
terraform {
  backend "s3" {
    bucket         = "BUCKET_NAME"
    key            = "vmware/terraform/infra.tfstate"
    dynamodb_table = "DAYNAMO_DB_TABLE_NAME"
    region         = "us-east-1"
    encrypt        = "true"
    profile        = "default"
  }
}