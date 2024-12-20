output "rds_secret_arn" {
  description = "The ARN of the secret"
  value = aws_secretsmanager_secret.rds_secret.arn
}

output "rds_secret_name" {
  description = "name of the secret"
  value = aws_secretsmanager_secret.rds_secret.name
}

output "generated_username" {
  value = random_password.rds_db_username.result
}

output "generated_password" {
  value = random_password.rds_db_password.result
  sensitive = true
}


