# logs.tf

# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "cb_log_group" {
  name              = "/ecs/sample-ecs-api"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_stream" "cb_log_stream" {
  name           = "sample-ecs-api-log-stream"
  log_group_name = aws_cloudwatch_log_group.cb_log_group.name
}