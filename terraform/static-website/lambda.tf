data "aws_iam_policy_document" "lambda_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_router" {
  name               = "${replace(var.domain_name, ".", "-")}-lambda-router"
  assume_role_policy = data.aws_iam_policy_document.lambda_policy.json
  provider           = aws.virginia

  tags = local.common_tags
}

resource "aws_lambda_function" "router" {
  provider      = aws.virginia
  function_name = "${replace(var.domain_name, ".", "-")}-static-website-router"
  publish       = true
  role          = aws_iam_role.lambda_router.arn
  runtime       = "nodejs12.x"

  filename = "${path.root}/target/router.zip"
  handler  = "router.handler"

  tags = local.common_tags
}
