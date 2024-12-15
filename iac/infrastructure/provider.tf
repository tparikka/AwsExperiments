# provider.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80.0"
    }
  }

  backend "s3" {
    bucket         = "awsexperiments-backend-tfstate-firstname-lastname" # Replace firstname-lastname with the developer name
    key            = "awsexperiments/sample-api-lambda"
    region         = "us-east-1"
    dynamodb_table = "tf-lock"
  }

  required_version = ">= 1.10.1"
}

provider "aws" {
  region = "us-east-1"
}