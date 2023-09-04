resource "aws_s3_bucket" "cf_logs" {
  bucket        = "${var.domain_name}-logs"
  force_destroy = true

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
    resources = [aws_s3_bucket.cf_logs.arn]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
    actions = [
      "s3:ListBucket",
      "s3:GetBucketAcl",
      "s3:PutBucketAcl"
    ]
  }
}

resource "aws_s3_bucket_ownership_controls" "cf_logs" {
  bucket = aws_s3_bucket.cf_logs.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "cf_logs" {
  depends_on = [aws_s3_bucket_ownership_controls.cf_logs]

  bucket = aws_s3_bucket.cf_logs.id
  access_control_policy {
    grant {
      grantee {
        type = "Group"
        uri  = "http://acs.amazonaws.com/groups/s3/LogDelivery"
      }
      permission = "FULL_CONTROL"
    }
  }
}

