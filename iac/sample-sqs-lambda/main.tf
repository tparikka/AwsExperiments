terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80.0"
    }
  }

  backend "s3" {
    bucket         = "tparikka-tfstate"
    key            = "awsexperiments/sample-sqs-lambda"
    profile        = "tparikka-dev"
    region         = "us-east-1"
    dynamodb_table = "tf-lock"
  }

  required_version = ">= 1.10.1"
}

provider "aws" {
  region  = "us-east-1"
  profile = "tparikka-dev"
}