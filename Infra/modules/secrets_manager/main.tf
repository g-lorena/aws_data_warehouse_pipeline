resource "aws_secretsmanager_secret" "rds_secret" {
  name        = var.rds_secret_name
  description = var.rds_secret_description
}

resource "random_string" "rds_db_username" {
  length  = 8
  special = false
  upper   = false
  lower   = true
  override_special = "_"
}

resource "random_password" "rds_db_password" {
  length  = 16
  special = true
  numeric = true
  upper   = true
  lower   = true
}

resource "aws_secretsmanager_secret_version" "rds_secret_credentials" {
  secret_id     = aws_secretsmanager_secret.rds_secret.id 
  secret_string = jsonencode({
    username = random_string.rds_db_username.result
    password = random_password.rds_db_password.result
  })
  depends_on = [aws_secretsmanager_secret.rds_secret]
}

resource "random_string" "redshift_db_username" {
  length  = 8
  special = false
  upper   = false
  lower   = true
  override_special = "_"
}

resource "random_password" "redshift_db_password" {
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

resource "aws_secretsmanager_secret_version" "redshift_secret_credentials" {
  secret_id = aws_secretsmanager_secret.redshift_secret.id
  secret_string = jsonencode({
    username = random_string.redshift_db_username.result #random_password.redshift_db_username.result
    password = random_password.redshift_db_password.result
    }
  )
}