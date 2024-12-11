# Retrieves the policy document that will allow AWS Lambda to operate
data "aws_iam_policy_document" "lambda_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Creates the AWS IAM role that will be delegated to the Lambda API
resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_api_lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_role.json
}

# Uses the release build output of the SampleLambdaApi project to build a ZIP file for deployment
data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "../../src/SampleApiLambda/bin/Release/net8.0/"
  output_path = "api_lambda_function_payload.zip"
}

# Triggers a fresh archive when the ZIP file hash changes
resource "null_resource" "lambda_update" {
  triggers = {
    trigger = filemd5(data.archive_file.lambda.output_path)
  }
}

# Deploys the Lambda with any required environment variables
resource "aws_lambda_function" "test_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = data.archive_file.lambda.output_path
  function_name = "sample_api_lambda"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "SampleApiLambda::SampleApiLambda.Function::FunctionHandler" # AssemblyName::FullClassNamespace::Method
  timeout       = 60

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "dotnet8"

  environment {
    variables = {
      LAMBDA_NET_SERIALIZER_DEBUG = "true"
    }
  }
  
  depends_on = [null_resource.lambda_update]
}

# Attaches the AWSLambdaBasicExecutionRole policy to the Lambda's execution role
# See also https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AWSLambdaBasicExecutionRole.html
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.iam_for_lambda.name
}

# Allows API Gateway to execute the Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.sample_api.execution_arn}/*"
}