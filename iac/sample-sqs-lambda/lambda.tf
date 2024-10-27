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
  name               = "iam_for_sqs_lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_role.json
}

resource "aws_iam_role_policy" "sns_policy" {
  role = aws_iam_role.iam_for_lambda.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "SNS:Publish"
        ]
        Effect   = "Allow"
        Resource = aws_sns_topic.user_updates.arn
      }
    ]
  })
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "../../src/SampleSqsLambda/bin/Release/net8.0/"
  output_path = "sqs_lambda_function_payload.zip"
}

resource "aws_lambda_function" "test_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = data.archive_file.lambda.output_path
  function_name = "sample_sqs_lambda"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "SampleSqsLambda::SampleSqsLambda.Function::FunctionHandler"
  timeout       = 60

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "dotnet8"

  environment {
    variables = {
      SnsTopicArn = aws_sns_topic.user_updates.arn
    }
  }
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.iam_for_lambda.name
}