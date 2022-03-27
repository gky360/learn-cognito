output "user_pool_id" {
  value = aws_cognito_user_pool.example.id
}

output "user_pool_name" {
  value = aws_cognito_user_pool.example.name
}

output "user_pool_client_id" {
  value = aws_cognito_user_pool_client.example_pub.id
}

output "user_pool_client_name" {
  value = aws_cognito_user_pool_client.example_pub.name
}

output "user_pool_domain" {
  value = aws_cognito_user_pool_domain.example.domain
}
