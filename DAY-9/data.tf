terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.23.0"
    }
  }
}

provider "aws" {

  region = "us-east-1"
  access_key = ""
  secret_key = ""
}



# Data block to get current AWS account ID
data "aws_caller_identity" "current" {}

# Data block to get current AWS region
data "aws_region" "current" {}

# Create simple S3 bucket (unique name using account-id + region)
resource "aws_s3_bucket" "mybucket" {
  bucket = "demo-bucket-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"

  tags = {
    Name = "SimpleBucket"
  }
}
