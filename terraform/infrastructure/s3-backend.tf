data "aws_iam_policy_document" "backend" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${var.bucket_name}",
      "arn:aws:s3:::${var.bucket_name}/*"
    ]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::427368570714:root"
      ]
    }
  }
}

resource "aws_s3_bucket" "backend" {
  bucket = var.bucket_name

  tags = merge(local.common_tags, {
    Description = "Backend for terraform state"
  })
}

resource "aws_s3_bucket_policy" "backend" {
  bucket = aws_s3_bucket.backend.id
  policy = data.aws_iam_policy_document.backend.json
}
