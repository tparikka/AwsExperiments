# ecr.tf

# The Elastic Container Registry (ECR) repository where container images may be stored, such as those created
# by the sample-ecs-api-image-build module
resource "aws_ecr_repository" "ecs_sample_api_repo" {
  name         = "sample-ecs-api"
  force_delete = true
}

# The policy of the ECR registry, which currently allows anything to push an image. Not for long term
# use of any kind.
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

# Defines the lifecycle policy of the ECR repository, limiting historical image retention to the last 3 images
# in order to save cost. In production loads, this limit would be higher and more complex to retain
# a better history of images that have been used in production.
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