terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }

  backend "s3" {
    bucket         = "awsexperiments-backend-tfstate-firstname-lastname"
    key            = "awsexperiments/ecr-with-build"
    region         = "us-east-1"
    dynamodb_table = "tf-lock"
  }

  required_version = ">= 1.10.1"
}

provider "aws" {
  region  = "us-east-1"
}

data "aws_caller_identity" "default" {}

provider "docker" {
  registry_auth {
    address  = "${data.aws_caller_identity.default.account_id}.dkr.ecr.us-east-1.amazonaws.com"
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}