terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80.0"
    }
  }

  required_version = ">= 1.10.1"
}

provider "aws" {
  region  = "us-east-1"
  profile = "tparikka-dev"
}

resource "aws_dynamodb_table" "lock_table" {
  name     = "tf-lock"
  read_capacity = 20
  write_capacity = 20
  billing_mode = "PROVISIONED"
  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_s3_bucket" "tfstate" {
  bucket = "tparikka-tfstate"
}