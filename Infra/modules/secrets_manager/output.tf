output "rds_secret_arn" {
  description = "The ARN of the secret"
  value = aws_secretsmanager_secret.rds_secret.arn
}

output "rds_secret_name" {
  description = "name of the secret"
  value = aws_secretsmanager_secret.rds_secret.name
}