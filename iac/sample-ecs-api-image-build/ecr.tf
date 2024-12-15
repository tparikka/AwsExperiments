# ecr.tf

# Retrieves data for the AWS Elastic Container Registry (ECR) repository where the image to be built
# will be stored
data "aws_ecr_repository" "ecs_sample_api_repo" {
  name         = "sample-ecs-api"
}

# Defines a Docker image build for the Elastic Container Service (ECS) cluster that will be created as a part
# of the sample-ecs-cluster module
resource "docker_image" "sample-ecs-api-image" {
  name = "${data.aws_ecr_repository.ecs_sample_api_repo.repository_url}:latest"
  build {
    context = "${path.module}/../../src/SampleEcsApi/"
  }
  platform = "linux/arm64"
}

# Defines the push of the image from the local Docker instance to ECR
resource "docker_registry_image" "ecs-api-repo-image" {
  name          = docker_image.sample-ecs-api-image.name
  keep_remotely = false # This causes tags to be deleted from the remote registry automatically. Not for production use.
}