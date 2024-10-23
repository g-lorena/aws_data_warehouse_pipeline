# create default vpc if one does not exit
resource "aws_vpc" "custom_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "default vpc"
  }
}

# use data source to get all avalablility zones in region
data "aws_availability_zones" "available_zones" {}


# create a default subnet in the first az if one does not exit
resource "aws_subnet" "subnet_az1" {
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available_zones.names[0]
}

# create a default subnet in the second az if one does not exit
resource "aws_subnet" "subnet_az2" {
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available_zones.names[1]
}

# create security group for the web server => we don't need this for our usecase
resource "aws_security_group" "webserver_security_group" {
  name        = "webserver security group"
  description = "enable http access on port 80"
  vpc_id      = aws_vpc.custom_vpc.id

  ingress {
    description      = "http access"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "webserver security group"
  }
}

# create security group for the database
resource "aws_security_group" "database_security_group" {
  name        = "database security group"
  description = "enable mysql/postgre access on port 3306"
  vpc_id      = aws_vpc.custom_vpc.id

  ingress {
    description      = "mysql/postgres"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    security_groups  = [aws_security_group.webserver_security_group.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "database security group"
  }
}

# create security group for the database
resource "aws_security_group" "lambda_security_group" {
  name        = "Lambda Security Group"
  description = "Lambda Security Group"
  vpc_id      = aws_vpc.custom_vpc.id

  ingress {
    description      = "lambda"
    from_port        = 0
    to_port          = 0
    protocol         = "tcp"
    security_groups  = [aws_security_group.webserver_security_group.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "lambda security group"
  }
}

resource "aws_db_subnet_group" "database_subnet_group" {
  name         = "database-subnets"
  subnet_ids   = [aws_subnet.subnet_az1.id, aws_subnet.subnet_az2.id]
  description  = "subnets for database instance"

  tags   = {
    Name = "database-subnets"
  }
}