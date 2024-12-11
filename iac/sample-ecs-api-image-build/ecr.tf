data "aws_ecr_repository" "ecs_sample_api_repo" {
  name         = "sample-ecs-api"
}

resource "time_static" "now" {}

resource "docker_image" "sample-ecs-api-image" {
  name = "${data.aws_ecr_repository.ecs_sample_api_repo.repository_url}:latest"
  build {
    context = "${path.module}/../../src/SampleEcsApi/"
  }
  platform = "linux/arm64"
}

resource "docker_registry_image" "ecs-api-repo-image" {
  name          = docker_image.sample-ecs-api-image.name
  keep_remotely = false
}