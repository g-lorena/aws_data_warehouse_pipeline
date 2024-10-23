variable "db_username" {
  type        = string
  description = "Username rds"
}

variable "db_password" {
  type        = string
  description = "password rds"
}

variable "db_name" {
  type        = string
  description = "db_name rds"
}

variable "db_subnet_group_name" {
  type        = string
  description = "db_subnet group_name"
}

variable "availability_zone" {
  type        = string
  description = "availability zone"
}

variable "vpc_security_group_ids" {
  type        = string
  description = "vpc_security_group_ids"
}