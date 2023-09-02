locals {
  github_actions_issuer_domain = "token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://${local.github_actions_issuer_domain}"
  thumbprint_list = ["1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
  client_id_list  = ["sts.amazonaws.com"]
  tags            = local.common_tags
}

data "aws_iam_policy_document" "github_provider_assume_actions" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.github_actions_issuer_domain}:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "${local.github_actions_issuer_domain}:sub"
      values   = ["repo:khaledez/khaledez.net:*"]
    }
  }
}

resource "aws_iam_role" "github-actions" {
  name = "${var.app_name}-github-actions"
  tags = local.common_tags

  assume_role_policy = data.aws_iam_policy_document.github_provider_assume_actions.json

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/CloudFrontFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
  ]

  inline_policy {
    name = "manage-domain"
    policy = jsonencode({
      version = "2012-10-17"
      effect  = "Allow"
      statement = {
        action = [
          "route53:GetHostedZone",
          "route53:ListHostedZones",
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets",
          "route53:GetHostedZoneCount",
          "route53:ListHostedZonesByName"
        ]
      }
      resource = [data.aws_route53_zone.primary.arn]
    })
  }

  lifecycle {
    create_before_destroy = true
  }
}
