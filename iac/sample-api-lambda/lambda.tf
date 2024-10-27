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

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_api_lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_role.json
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "../../src/SampleApiLambda/bin/Release/net8.0/"
  output_path = "api_lambda_function_payload.zip"
}

resource "null_resource" "lambda_update" {
  triggers = {
    trigger = filemd5(data.archive_file.lambda.output_path)
  }
}

resource "aws_lambda_function" "test_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = data.archive_file.lambda.output_path
  function_name = "sample_api_lambda"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "SampleApiLambda::SampleApiLambda.Function::FunctionHandler"
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

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.iam_for_lambda.name
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.sample_api.execution_arn}/*"
}