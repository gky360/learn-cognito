locals {
  project_name = "learn-cognito"
  env_name     = "dev"
  prefix       = "${local.project_name}-${local.env_name}-"

  default_tags = {
    Project     = local.project_name
    Environment = local.env_name
    ManagedBy   = "terraform"
    Cost        = local.project_name
  }
}

# resource "aws_cognito_user_pool" "this" {
# }
