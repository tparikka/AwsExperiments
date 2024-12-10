locals {
  container_name = "sample-ecs-api"
  container_port = 8080
}

data "aws_ecr_authorization_token" "this" {}

data "aws_ecr_repository" "ecs_sample_api_repo" {
  name = "sample-ecs-api"
}