# apigateway.tf

# Defines the main API Gateway instance, which will contain various other resources. The benefit of API Gateway is
# that it serves as a central point of aggregation and obfuscates the backing service from the endpoint to be called.
resource "aws_api_gateway_rest_api" "sample_api" {
  name        = "my-api"
  description = "My API Gateway"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# The gateway resource refers to an HTTP resource that is exposed by the API Gateway according to the rules of
# HTTP. See also https://devblast.com/b/what-are-http-resources
resource "aws_api_gateway_resource" "root" {
  rest_api_id = aws_api_gateway_rest_api.sample_api.id
  parent_id   = aws_api_gateway_rest_api.sample_api.root_resource_id
  path_part   = "api"
}

# For each resource, various HTTP verbs may be supported such as GET, POST, PATCH, DELETE, etc. Each verb
# to be supported will get it own aws_api_gateway_method on the resource. Authorization, such as by
# authorizer Lambda or other, is also specified at this level.
resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.sample_api.id
  resource_id   = aws_api_gateway_resource.root.id
  http_method   = "GET"
  authorization = "NONE"
}

# Integrates an aws_api_gateway_method to some type of interaction. AWS Lambda is a common type of integration, as are
# passthroughs to other APIs such as those hosted in Elastic Container Service (ECS) / Elastic Kubernetes Service (EKS)
# or Elastic Compute Cloud (EC2).
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.sample_api.id
  resource_id             = aws_api_gateway_resource.root.id
  http_method             = aws_api_gateway_method.proxy.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  # In this instance, the URI is the Amazon Resource Name (ARN) of the Lambda to be invoked
  uri                     = aws_lambda_function.test_lambda.invoke_arn
}

# The integration response router through which the response is sent. For some response types, this integration
# response may transform the response to meet a different format, such as SOAP to JSON or the inverse to allow
# a modern API backend to expose a compatibility layer to legacy clients.
resource "aws_api_gateway_integration_response" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.sample_api.id
  resource_id = aws_api_gateway_resource.root.id
  http_method = aws_api_gateway_method.proxy.http_method
  status_code = aws_api_gateway_method_response.proxy.status_code

  depends_on = [
    aws_api_gateway_method.proxy,
    aws_api_gateway_integration.lambda_integration
  ]
}

# Provides a status code and last checkpoint for the response before it is sent to the caller.
resource "aws_api_gateway_method_response" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.sample_api.id
  resource_id = aws_api_gateway_resource.root.id
  http_method = aws_api_gateway_method.proxy.http_method
  status_code = "200"
}

# API Gateway endpoints must be deployed to be functional. This resource defines the main shell of a deploy path.
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.sample_api.id
}

# Defines a stage of deployment. Typical stages might include "staging" and "live" or "production". For this demo
# we define only a "staging" stage.
resource "aws_api_gateway_stage" "development" {

  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.sample_api.id
  stage_name    = "staging"
}

# Permissions

# The policy below can be uncommented to restrict callers to a range of IP addresses.
# data "aws_iam_policy_document" "test" {
#   statement {
#     effect = "Allow"
# 
#     principals {
#       type        = "AWS"
#       identifiers = ["*"]
#     }
# 
#     actions   = ["execute-api:Invoke"]
#     resources = ["${aws_api_gateway_stage.development.execution_arn}/*"]
# 
#     condition {
#       test     = "IpAddress"
#       variable = "aws:SourceIp"
#       values   = ["161.188.222.0/24"]
#     }
#   }
# }

# resource "aws_api_gateway_rest_api_policy" "test" {
#   rest_api_id = aws_api_gateway_rest_api.sample_api.id
#   policy      = data.aws_iam_policy_document.test.json
# }