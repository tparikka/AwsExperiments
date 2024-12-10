data "aws_ecr_repository" "ecs_sample_api_repo" {
  name         = "sample-ecs-api"
}

resource "aws_ecr_repository_policy" "ecr_repo_policy" {
  repository = data.aws_ecr_repository.ecs_sample_api_repo.name

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
  repository = data.aws_ecr_repository.ecs_sample_api_repo.name

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

resource "docker_image" "sample-ecs-api-image" {
  #name = "${data.aws_ecr_repository.ecs_sample_api_repo.repository_url}:latest"
  name = "tparikka/sample-ecs-api:latest"
  build {
    context = "${path.module}/../../src/SampleEcsApi/"
  }
  platform = "linux/arm64"
}

# resource "docker_registry_image" "ecs-api-repo-image" {
#   name          = docker_image.sample-ecs-api-image.name
#   keep_remotely = false
# }