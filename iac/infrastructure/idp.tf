# The OIDC Identity Provider to be created that will connect AWS to GitHub
# Refer to the main README.md to see how to pass the correct thumbprint value here
resource "aws_iam_openid_connect_provider" "github_idp" {
  url = "https://token.actions.githubusercontent.com"
  client_id_list = [
    "sts.amazonaws.com"
  ]
  thumbprint_list = [
    var.idp_thumbprint
  ]
}

# Creates the IAM role that will allow a specific GitHub repository to interact with AWS. See the main README.md
# to see how to specify the developer's account ID and repository values.
resource "aws_iam_role" "github_aws_action" {
  name = "GitHubAction-AssumeRoleWithAction"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17"
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${var.account_id}:oidc-provider/token.actions.githubusercontent.com"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          },
          "StringLike" : {
            "token.actions.githubusercontent.com:sub" : "repo:${var.github_repository}:*"
          }
        }
      }
    ],
  })
}