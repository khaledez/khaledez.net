resource "aws_s3_bucket" "cf_logs" {
  bucket = "${var.app_name}-logs"

  tags = local.common_tags
}

resource "aws_s3_bucket_policy" "cf_logs_policy" {
  bucket = aws_s3_bucket.cf_logs.id
  policy = data.aws_iam_policy_document.cf_logs_policy.json
}

data "aws_iam_policy_document" "cf_logs_policy" {
  statement {
    actions   = ["s3:*Object"]
    resources = ["${aws_s3_bucket.cf_logs.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.cf_logs.arn]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }
}
