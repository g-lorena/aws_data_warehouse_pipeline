output "aws_db_instance_arn" {
  value = aws_db_instance.db_instance.arn
  description = "arn of the db_instance "
}

output "rds_endpoint" {
  value = aws_db_instance.db_instance.endpoint
  description = "arn of the db_instance "
}

output "rds_host" {
  value       = split(":", aws_db_instance.db_instance.endpoint)[0]
  description = "Host of the RDS instance"
}

output "rds_port" {
  value       = split(":", aws_db_instance.db_instance.endpoint)[1]
  description = "Port of the RDS instance"
}
