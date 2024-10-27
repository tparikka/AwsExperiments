resource "aws_api_gateway_rest_api" "sample_api" {
  name        = "my-api"
  description = "My API Gateway"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "root" {
  rest_api_id = aws_api_gateway_rest_api.sample_api.id
  parent_id   = aws_api_gateway_rest_api.sample_api.root_resource_id
  path_part   = "api"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.sample_api.id
  resource_id   = aws_api_gateway_resource.root.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.sample_api.id
  resource_id             = aws_api_gateway_resource.root.id
  http_method             = aws_api_gateway_method.proxy.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.test_lambda.invoke_arn
}

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

resource "aws_api_gateway_method_response" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.sample_api.id
  resource_id = aws_api_gateway_resource.root.id
  http_method = aws_api_gateway_method.proxy.http_method
  status_code = "200"
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.sample_api.id
}

resource "aws_api_gateway_stage" "development" {

  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.sample_api.id
  stage_name    = "development"
}

# Permissions

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