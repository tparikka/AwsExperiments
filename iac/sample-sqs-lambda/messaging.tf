# messaging.tf

# Creates a Simple Queue Service (SQS) queue that will be used as an event source for the Lambda
resource "aws_sqs_queue" "test_queue" {
  name          = "sample-sqs-queue"
  delay_seconds = 2
  visibility_timeout_seconds = 120
}

# Attaches the SQS queue as an event source for the Lambda
resource "aws_lambda_event_source_mapping" "test_mapping" {
  function_name = aws_lambda_function.test_lambda.arn
  event_source_arn = aws_sqs_queue.test_queue.arn
}

# Creates a Simple Notification Service (SNS) topic to which messages can be sent. Typically in an event driven
# architecture that leverages SNS and SQS, messages will be first sent to SNS and then various
# destinations such as SQS will subscribe to the topic so that multiple consumers can receive the same message.
resource "aws_sns_topic" "user_updates" {
  name = "user-updates-topic"
}

# Subscribes the following email address to updates for the previously created SNS topic.
resource "aws_sns_topic_subscription" "user_update_email" {
  #endpoint  = "first.last.nosuchemailexists@gmail.com"
  endpoint  = "thomas.parikka@gmail.com"
  protocol  = "email"
  topic_arn = aws_sns_topic.user_updates.arn
}

# Establishes the IAM policy to govern the above SNS topic.
data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission"
    ]

    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.user_updates.arn
    ]

    sid = "__default_statement_ID"
  }
}

# Attaches the SNS topic policy to the SNS topic.
resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.user_updates.arn

  policy = data.aws_iam_policy_document.sns_topic_policy.json
}