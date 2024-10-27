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
    bucket         = "tparikka-tfstate"
    key            = "awsexperiments/ecr"
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

provider "docker" {
  registry_auth {
    address  = data.aws_ecr_authorization_token.token.proxy_endpoint
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}
resource "aws_ecr_repository" "ecs_sample_api_repo" {
  name         = "sample-ecs-api"
  force_delete = true
}

resource "aws_ecr_lifecycle_policy" "ecs_sample_api_repo_lifecycle" {
  repository = aws_ecr_repository.ecs_sample_api_repo.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 3 images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 3
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

data "aws_ecr_authorization_token" "token" {}

# Tests running a container locally
# resource "docker_image" "sample_ecs_api" {
#   name = "sample-ecs-api:latest"
#   build {
#     context = "${path.module}/../../src/SampleEcsApi/"
#   }
# }

# resource "docker_container" "pure_app" {
#   name  = "pure_app"
#   image = docker_image.sample_ecs_api.name  # Uses output from data source
#   ports {
#     internal = 8080
#     external = 8080
#   }
# }

# Tests building a docker image and pushing it to ECR
# resource "docker_image" "sample-ecs-api-image" {
#   #name = "${aws_ecr_repository.my-ecr-repo.repository_url}:latest"
#   name = "${data.aws_ecr_authorization_token.token.proxy_endpoint}/my-ecr-repo:latest"
#   build {
#     context = "${path.module}/../../src/SampleEcsApi/"
#   }
#   platform = "linux/arm64"
# }
# 
# resource "docker_registry_image" "ecs-api-repo-image" {
#   name          = docker_image.sample-ecs-api-image.name
#   keep_remotely = false
# }