output "rds_secret_arn" {
  description = "The ARN of the secret"
  value = aws_secretsmanager_secret.rds_secret.arn
}

output "rds_secret_name" {
  description = "name of the secret"
  value = aws_secretsmanager_secret.rds_secret.name
}

output "generated_username" {
  value = "a${random_string.rds_db_username.result}" #random_string.rds_db_username.result
}

output "generated_password" {
  value = random_password.rds_db_password.result
  sensitive = true
}

output "generated_redshift_username" {
  value = "a${random_string.redshift_db_username.result}" #random_string.redshift_db_username.result
  #random_password.redshift_db_username.result
}

output "generated_redshift_password" {
  value = random_password.redshift_db_password.result
}


