output "access_key_id" {
  value       = aws_iam_access_key.airbyte_access_key.id
  description = "The AWS Access Key ID for the Airbyte user"
  sensitive   = true
}

output "secret_access_key" {
  value       = aws_iam_access_key.airbyte_access_key.secret
  description = "The AWS Secret Access Key for the Airbyte user"
  sensitive   = true
}