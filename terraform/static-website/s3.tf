# resource "aws_s3_bucket" "s3_website" {
#   bucket        = var.domain_name
#   force_destroy = true

#   tags = local.common_tags
# }

# resource "aws_s3_bucket_policy" "s3_website_policy" {
#   bucket = aws_s3_bucket.s3_website.id
#   policy = data.aws_iam_policy_document.s3_policy.json
# }

# data "aws_iam_policy_document" "s3_policy" {
#   statement {
#     actions   = ["s3:GetObject"]
#     resources = ["${aws_s3_bucket.s3_website.arn}/*"]

#     principals {
#       type        = "AWS"
#       identifiers = [module.tf_next.api_endpoint_access_policy_arn]
#     }
#   }

#   statement {
#     actions   = ["s3:ListBucket"]
#     resources = [aws_s3_bucket.s3_website.arn]

#     principals {
#       type        = "AWS"
#       identifiers = [module.tf_next.api_endpoint_access_policy_arn]
#     }
#   }
# }