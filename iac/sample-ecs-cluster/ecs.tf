# ecs.tf

# Retrieves information about the Elastic Container Registry (ECR) repository where the image to be deployed resides.
data "aws_ecr_repository" "ecs_sample_api_repo" {
  name = "sample-ecs-api"
}

# Deploys the main AWS ECS cluster, within which the service and task definition will be added
resource "aws_ecs_cluster" "main" {
  name = "sample-ecs-api-cluster"
}

# Deploys the ECS service definition, which is a collection of tasks related to a specific workload
resource "aws_ecs_service" "main" {
  name            = "sample-ecs-api-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  # The VPC network and security groups to which the service will be attached
  # See also network.tf
  network_configuration {
    security_groups = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
  }

  # The Application Load Balancer that will distribute traffic to services in the cluster
  # See also alb.tf
  load_balancer {
    target_group_arn = aws_alb_target_group.app.id
    container_name   = local.container_name
    container_port   = var.app_port
  }

  # Helps Terraform to know which resources must be instantiated before this resource may be created
  depends_on = [aws_alb_listener.front_end, aws_iam_role_policy_attachment.ecs-task-execution-role-policy-attachment]
}

# The definition of the containers that must run tasks for the service.
resource "aws_ecs_task_definition" "app" {
  family             = "sample-ecs-app-task"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  network_mode       = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                = var.fargate_cpu
  memory             = var.fargate_memory
  container_definitions = jsonencode([
    {
      name        = local.container_name
      image       = var.app_image
      cpu         = var.fargate_cpu
      memory      = var.fargate_memory
      networkMode = "awsvpc"
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/sample-ecs-api"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"

        }
      }
      portMappings = [
        {
          containerPort = local.container_port
          hostPort      = var.app_port
        }
      ]
    }
  ])
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  depends_on = [aws_cloudwatch_log_group.cb_log_group]
}