locals {
  prefix = "${var.project_name}-${var.env_name}-"

  default_tags = {
    Project     = var.project_name
    Environment = var.env_name
    ManagedBy   = "terraform"
    Cost        = var.project_name
  }
}

// Cognito User Pool

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
    required                 = true

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

resource "aws_cognito_user_pool_client" "example_pub" {
  name         = "${local.prefix}example-pub"
  user_pool_id = aws_cognito_user_pool.example.id

  access_token_validity  = 60
  id_token_validity      = 60
  refresh_token_validity = 30

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

  allowed_oauth_flows = [
    "code",
  ]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes = [
    "email",
    "openid",
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
  logout_urls                   = []
  prevent_user_existence_errors = "ENABLED"
}

// S3

resource "aws_s3_bucket" "media" {
  bucket = "${local.prefix}media"
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.media.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "media" {
  bucket                  = aws_s3_bucket.media.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "restricted_image" {
  bucket = aws_s3_bucket.media.id
  key    = "shared/restricted.gif"
  source = "./media/shared/restricted.gif"
  etag   = filemd5("./media/shared/restricted.gif")
}

resource "aws_s3_object" "private_image" {
  bucket = aws_s3_bucket.media.id
  key    = "private.gif"
  source = "./media/private.gif"
  etag   = filemd5("./media/private.gif")
}

// CDN

data "aws_cloudfront_cache_policy" "chaching_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_origin_request_policy" "cors_s3origin" {
  name = "Managed-CORS-S3Origin"
}

resource "aws_cloudfront_origin_access_identity" "this" {
  comment = "origin access identity for s3"
}

resource "aws_cloudfront_distribution" "this" {
  enabled         = true
  is_ipv6_enabled = true

  origin {
    domain_name = aws_s3_bucket.media.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.media.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
      "OPTIONS",
    ]
    cached_methods = [
      "GET",
      "HEAD",
    ]

    target_origin_id         = aws_s3_bucket.media.id
    cache_policy_id          = data.aws_cloudfront_cache_policy.chaching_optimized.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.cors_s3origin.id
    compress                 = true
    viewer_protocol_policy   = "redirect-to-https"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

data "aws_iam_policy_document" "analysis_media_bucket_policy_document" {
  statement {
    actions = ["s3:GetObject"]

    resources = [
      "${aws_s3_bucket.media.arn}/*",
    ]

    principals {
      type = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.this.iam_arn,
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "analysis_media_bucket_policy" {
  bucket = aws_s3_bucket.media.id
  policy = data.aws_iam_policy_document.analysis_media_bucket_policy_document.json
}
