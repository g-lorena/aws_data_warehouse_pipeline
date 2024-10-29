# create default vpc if one does not exit
resource "aws_vpc" "custom_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "data-warehouse-vpc"
  }
}

# use data source to get all avalablility zones in region
data "aws_availability_zones" "available_zones" {}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch  = true
}

# create a default subnet in the first az if one does not exit
resource "aws_subnet" "subnet_az1" {
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available_zones.names[0]

  tags = {
    Name = "private_subnet_az1"
  }
}

# create a default subnet in the second az if one does not exit
resource "aws_subnet" "subnet_az2" {
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = data.aws_availability_zones.available_zones.names[1]

  tags = {
    Name = "private_subnet_az2"
  }

}
/*
locals {
  subnets = {
    "subnet_az1" = {
      cidr_block        = aws_subnet.subnet_az1.cidr_block
      availability_zone = aws_subnet.subnet_az1.availability_zone
      tag_name          = aws_subnet.subnet_az1.tags["Name"]
    }
    "subnet_az2" = {
      cidr_block        = aws_subnet.subnet_az2.cidr_block
      availability_zone = aws_subnet.subnet_az2.availability_zone
      tag_name          = aws_subnet.subnet_az2.tags["Name"]
    }
  }
}

resource "aws_subnet" "private-subnets" {
  for_each = local.subnets

  cidr_block        = each.value.cidr_block
  vpc_id            = aws_vpc.custom_vpc.id
  availability_zone = each.value.availability_zone

  tags = {
    Name = each.value.tag_name
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    Name = "Internet Gateway"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}
*/

resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.custom_vpc.id

    tags = {
        Name = "Private Route Table"
    }
}

resource "aws_route_table_association" "private_subnet1_association" {
    #for_each       = aws_subnet.private-subnets
    #subnet_id      = each.value.id
    #route_table_id = aws_route_table.private_route_table.id

    subnet_id      = aws_subnet.subnet_az1.id # Replace with your private subnet ID
    route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet2_association" {
    #for_each       = aws_subnet.private-subnets
    #subnet_id      = each.value.id
    #route_table_id = aws_route_table.private_route_table.id

    subnet_id      = aws_subnet.subnet_az2.id # Replace with your private subnet ID
    route_table_id = aws_route_table.private_route_table.id
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id          = aws_vpc.custom_vpc.id
  vpc_endpoint_type = "Gateway"
  service_name    = "com.amazonaws.eu-west-3.dynamodb"
  #security_group_ids = [aws_security_group.lambda_security_group.id]
  route_table_ids = [aws_route_table.private_route_table.id]
  #subnet_ids        = [aws_subnet.subnet_az1.id, aws_subnet.subnet_az2.id]
  tags = {
    Name = "DynamoDB VPC Endpoint"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id             = aws_vpc.custom_vpc.id
  vpc_endpoint_type  = "Gateway"
  service_name       = "com.amazonaws.eu-west-3.s3" # Adjust this for your region
  route_table_ids    = [aws_route_table.private_route_table.id] # You can include multiple route tables

  tags = {
    Name = "S3 VPC Endpoint"
  }
}

  #route_table_ids = [aws_route_table.private_route_table.id] # If your Lambda runs in private subnets, you might use a private route table instead



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
resource "aws_security_group" "lambda_security_group" {
  name        = "Lambda Security Group"
  description = "Lambda Security Group"
  vpc_id      = aws_vpc.custom_vpc.id

/*
  ingress {
    description      = "lambda"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    #security_groups  = [aws_security_group.webserver_security_group.id]
  }
*/
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
    security_groups  = [aws_security_group.lambda_security_group.id]
    #cidr_blocks      = ["0.0.0.0/0"] #
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

resource "aws_security_group" "redshift_sg" {
  name        = "redshift_sg"
  description = "Allow access to Redshift"

  ingress {
    from_port   = 5439  # Redshift default port
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_redshift_subnet_group" "redshift_subnet_group" {
  name       = "redshift-subnets"
  subnet_ids = [aws_subnet.subnet_az1.id, aws_subnet.subnet_az2.id]  
}


resource "aws_db_subnet_group" "database_subnet_group" {
  name         = "database-subnets"
  subnet_ids   = [aws_subnet.subnet_az1.id, aws_subnet.subnet_az2.id]
  

  description  = "subnets for database instance"

  tags   = {
    Name = "database-subnets"
  }
}