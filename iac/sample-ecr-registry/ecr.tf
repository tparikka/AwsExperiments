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