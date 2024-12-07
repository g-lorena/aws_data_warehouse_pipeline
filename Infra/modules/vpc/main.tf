terraform {
    required_providers {
      null = {
        source = "hashicorp/null"
        version = "3.2.3"
      }
    }
}

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
data "aws_availability_zones" "available_zones" {
  state = "available"
}

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

resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.custom_vpc.id

    tags = {
        Name = "Private Route Table"
    }
}

resource "aws_route_table_association" "public_subnet_association"{
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_subnet1_association" {
    subnet_id      = aws_subnet.subnet_az1.id 
    route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet2_association" {
    subnet_id      = aws_subnet.subnet_az2.id 
    route_table_id = aws_route_table.private_route_table.id
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id          = aws_vpc.custom_vpc.id
  vpc_endpoint_type = "Gateway"
  service_name    = "com.amazonaws.eu-west-3.dynamodb"
  route_table_ids = [aws_route_table.private_route_table.id]
  tags = {
    Name = "DynamoDB VPC Endpoint"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id             = aws_vpc.custom_vpc.id
  vpc_endpoint_type  = "Gateway"
  service_name       = "com.amazonaws.eu-west-3.s3"
  route_table_ids    = [aws_route_table.private_route_table.id] # You can include multiple route tables

  tags = {
    Name = "S3 VPC Endpoint"
  }
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
    security_groups  = [aws_security_group.lambda_security_group.id, aws_security_group.bastion_sg.id]
    cidr_blocks      = [
      "93.21.130.146/32",
      "13.37.4.46/32",
      "13.37.142.60/32",
      "35.181.124.238/32"] #
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

data "aws_ami" "amazon_linux_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-gp2"]#["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"] # Canonical
}

resource "aws_key_pair" "generated_bastion_key" {
  key_name   = "aws-bastion-key"
  public_key = file(var.public_key_path) 
}

# Security group for the bastion
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  vpc_id      = aws_vpc.custom_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["93.21.130.146/32", "13.37.4.46/32", "13.37.142.60/32", "35.181.124.238/32"] 
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
        Name = "bastion-ec2"
    }
}

resource "aws_instance" "bastion" {
  ami           = data.aws_ami.amazon_linux_ami.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public_subnet.id
  key_name =  aws_key_pair.generated_bastion_key.key_name 

  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "BastionHost"
  }
  depends_on = [ aws_vpc.custom_vpc ]
}

resource "aws_eip" "bastion_instance_eip" {
  instance = aws_instance.bastion.id
  domain   = "vpc"
  depends_on = [ aws_vpc.custom_vpc, aws_instance.bastion ]
}

resource "null_resource" "keys_to_ec2_bastion_instance" {

  connection {
    type = "ssh"
    host = aws_eip.bastion_instance_eip.public_ip
    user = "ec2-user"
    password = ""
    timeout  = "5m"
    
    private_key = file(var.private_key_path)
  }
  provisioner "file" {
    source      = var.private_key_path
    destination = "/tmp/aws-bastion-key.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod 400 /tmp/aws-bastion-key.pem"
    ]
  }
  depends_on = [
    aws_instance.bastion
  ]

}

resource "aws_security_group" "redshift_sg" {
  name        = "redshift_sg"
  description = "Allow access to Redshift"
  vpc_id      = aws_vpc.custom_vpc.id

  ingress {
    from_port   = 5439  # Redshift default port
    to_port     = 5439
    protocol    = "tcp"
    security_groups  = [aws_security_group.lambda_security_group.id, aws_security_group.bastion_sg.id]
    cidr_blocks      = [
      "93.21.130.146/32",
      "13.37.4.46/32",
      "13.37.142.60/32",
      "35.181.124.238/32"]    
    
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
