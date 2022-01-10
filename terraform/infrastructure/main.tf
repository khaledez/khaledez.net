locals {
  common_tags = {
    Environment = var.environment
    App         = var.app_name
  }
}