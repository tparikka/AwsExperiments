resource "aws_sns_topic" "user_updates" {
  name = "user-updates-topic"
}

resource "aws_sns_topic_subscription" "user_update_email" {
  endpoint  = "thomas.parikka@gmail.com"
  protocol  = "email"
  topic_arn = aws_sns_topic.user_updates.arn
}

resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.user_updates.arn

  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

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
      "SNS:AddPermission",
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