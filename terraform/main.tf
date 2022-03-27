locals {
  prefix = "${var.project_name}-${var.env_name}-"

  default_tags = {
    Project     = var.project_name
    Environment = var.env_name
    ManagedBy   = "terraform"
    Cost        = var.project_name
  }
}

resource "aws_cognito_user_pool" "example" {
  name = "${local.prefix}example"

  auto_verified_attributes = [
    "email",
  ]
  mfa_configuration = "OFF"
  username_attributes = [
    "email",
  ]

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  schema {
    attribute_data_type      = "Number"
    developer_only_attribute = false
    mutable                  = true
    name                     = "updated_at"
    required                 = true

    number_attribute_constraints {
      min_value = "0"
    }
  }
  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"

    required = true
    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }

  username_configuration {
    case_sensitive = false
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
  }
}

resource "aws_cognito_user_pool_domain" "example" {
  domain       = "${local.prefix}example"
  user_pool_id = aws_cognito_user_pool.example.id
}

resource "aws_cognito_user_pool_client" "example_pub" {
  name         = "${local.prefix}example-pub"
  user_pool_id = aws_cognito_user_pool.example.id

  access_token_validity = 60
  allowed_oauth_flows = [
    "code",
  ]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes = [
    "email",
  ]
  callback_urls = [
    "http://localhost:3000",
  ]
  enable_token_revocation = true
  explicit_auth_flows = [
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
  ]
  id_token_validity             = 60
  logout_urls                   = []
  prevent_user_existence_errors = "ENABLED"
  # read_attributes = [
  #   "address",
  #   "birthdate",
  #   "email",
  #   "email_verified",
  #   "family_name",
  #   "gender",
  #   "given_name",
  #   "locale",
  #   "middle_name",
  #   "name",
  #   "nickname",
  #   "phone_number",
  #   "phone_number_verified",
  #   "picture",
  #   "preferred_username",
  #   "profile",
  #   "updated_at",
  #   "website",
  #   "zoneinfo",
  # ]
  refresh_token_validity = 30
  # supported_identity_providers = [
  #   "COGNITO",
  # ]
  # write_attributes = [
  #   "address",
  #   "birthdate",
  #   "email",
  #   "family_name",
  #   "gender",
  #   "given_name",
  #   "locale",
  #   "middle_name",
  #   "name",
  #   "nickname",
  #   "phone_number",
  #   "picture",
  #   "preferred_username",
  #   "profile",
  #   "updated_at",
  #   "website",
  #   "zoneinfo",
  # ]

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }
}
