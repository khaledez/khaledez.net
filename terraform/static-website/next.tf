##########################
# Terraform Next.js Module
##########################

module "tf_next" {
  source  = "milliHQ/next-js/aws"
  version = "1.0.0-canary.4"

  cloudfront_aliases             = local.aliases
  cloudfront_acm_certificate_arn = data.aws_acm_certificate.domain_cert.arn

  deployment_name = "atomic-deployments"

  enable_multiple_deployments = false

  providers = {
    aws.region = "us-east-1"
  }
}

#########
# Outputs
#########

output "api_endpoint" {
  value = module.tf_next.api_endpoint
}

output "api_endpoint_access_policy_arn" {
  value = module.tf_next.api_endpoint_access_policy_arn
}
