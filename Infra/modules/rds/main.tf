# create the rds instance
resource "aws_db_instance" "db_instance" {
  engine                  = "postgres"
  engine_version          = "16.4"
  multi_az                = false
  identifier              = "dev-rds-instance"
  username                = var.db_username
  password                = var.db_password
  instance_class          = "db.t3.micro"
  allocated_storage       = 200
  db_subnet_group_name    = var.db_subnet_group_name #aws_db_subnet_group.database_subnet_group.name
  vpc_security_group_ids  = [var.vpc_security_group_ids] #[aws_security_group.database_security_group.id]
  availability_zone       = var.availability_zone #data.aws_availability_zones.available_zones.names[0]
  db_name                 = var.db_name
  skip_final_snapshot     = true
}