output "vpc_id" {
    value = aws_vpc.custom_vpc.id
}

output "subnet_ids" {
  value = [aws_subnet.subnet_az1.id, aws_subnet.subnet_az2.id]
}

output "lambda_security_group_id" {
  value = aws_security_group.lambda_security_group.id
}

output "database_security_group_id" {
  value = aws_security_group.database_security_group.id
}

output "database_subnet_group_name" {
  value = aws_db_subnet_group.database_subnet_group.name
}

output "availability_zone_name" {
  value = data.aws_availability_zones.available_zones.names[0]
}

output "aws_redshift_subnet_group_name" {
  value = aws_redshift_subnet_group.redshift_subnet_group.name
}
output "redshift_sg_id" {
  value = aws_security_group.redshift_sg.id
}