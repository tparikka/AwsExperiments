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
    key            = "awsexperiments/ecr-with-build"
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
    address  = "${data.aws_caller_identity.default.account_id}.dkr.ecr.us-east-1.amazonaws.com"
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}

locals {
  docker_image_name = "sample-ecs-api-with-build"
}

data "aws_caller_identity" "default" {}

resource "aws_ecr_repository" "ecs_sample_api_repo" {
  name         = local.docker_image_name
  force_delete = true
}

resource "aws_ecr_repository_policy" "ecr_repo_policy" {
  repository = aws_ecr_repository.ecs_sample_api_repo.name

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "new policy",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:DescribeRepositories",
                "ecr:GetRepositoryPolicy",
                "ecr:ListImages",
                "ecr:DeleteRepository",
                "ecr:BatchDeleteImage",
                "ecr:SetRepositoryPolicy",
                "ecr:DeleteRepositoryPolicy"
            ]
        }
    ]
}
EOF
}

resource "time_static" "now" {}

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

#Tests building a docker image and pushing it to ECR
resource "docker_registry_image" "my_docker_image" {
  name = "${aws_ecr_repository.ecs_sample_api_repo.repository_url}:build-${time_static.now.unix}"

  build {
    context = "${path.module}/src"
    labels = {
      dir_sha1 = sha1(join("", [for f in fileset("${path.module}/src", "*") : filesha1("${path.module}/src/${f}")]))
    }
  }
}

# 
# resource "docker_image" "sample-ecs-api-image" {
#   name = "${aws_ecr_repository.ecs_sample_api_repo.repository_url}:latest"
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