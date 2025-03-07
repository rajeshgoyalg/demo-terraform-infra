resource "aws_iam_role" "github_actions_role" {
  name = "github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${var.aws_account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:rajeshgoyalg/demo-flask-app:*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "github_actions_policy" {
  name        = "github-actions-policy"
  description = "Policy to allow GitHub Actions to deploy to ECS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "ecs:UpdateService",
          "ecs:RegisterTaskDefinition",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeServices",
          "ecs:ListTasks",
          "ecs:DescribeTasks",
          "iam:PassRole"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = "ecr:GetAuthorizationToken"
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::terraform-state-devopsai/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_attachment" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_actions_policy.arn
}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = ["a031c46782e6e6c662c2c87c76da9aa62ccabd8e"] # Update with latest from AWS docs
}