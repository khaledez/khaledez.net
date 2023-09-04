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
    "arn:aws:iam::aws:policy/AWSCertificateManagerFullAccess"
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_policy_attachment" "manage_domain" {
  name       = "${var.app_name}-manage-domain"
  roles      = [aws_iam_role.github-actions.name]
  policy_arn = aws_iam_policy.manage_domain.arn
}

resource "aws_iam_policy" "manage_domain" {
  name   = "${var.app_name}-manage-domain"
  path   = "/"
  policy = data.aws_iam_policy_document.manage_domain.json
  tags   = local.common_tags
}

data "aws_iam_policy_document" "manage_domain" {
  statement {
    sid = "ManageRoute53Domain"
    actions = [
      "route53:GetHostedZone",
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
      "route53:GetHostedZoneCount",
      "route53:ListTagsForResource"
    ]
    resources = [data.aws_route53_zone.primary.arn]
  }
  statement {
    sid = "ListHostedZones"
    actions = [
      "route53:ListHostedZones",
      "route53:ListHostedZonesByName"
    ]
    resources = ["*"]
  }
}
