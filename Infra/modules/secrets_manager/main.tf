resource "aws_secretsmanager_secret" "rds_secret" {
  name        = var.rds_secret_name
  description = var.rds_secret_description
}

resource "aws_secretsmanager_secret_version" "service_user" {
  secret_id     = aws_secretsmanager_secret.rds_secret.id #aws_secretsmanager_secret.service_user.id
  #secret_string = var.api_username

  secret_string = jsonencode(var.rds_secret_values)
}

resource "random_password" "service_password" {
  length  = 16
  special = true
  numeric = true
  upper   = true
  lower   = true
}

resource "aws_secretsmanager_secret" "redshift_secret" {
  name        = var.redshift_secret_name
  description = var.redshift_secret_description
}