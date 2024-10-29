variable "cluster_subnet_group_name" {
  description = "cluster_subnet_group_name"
  type        = string
}

variable "cluster_type" {
  description = "cluster_type"
  type        = string
}

variable "node_type" {
  description = "node_type"
  type        = string
}

variable "master_password" {
  description = "master_password"
  type        = string
}

variable "master_username" {
  description = "master_username"
  type        = string
}

variable "database_name" {
  description = "database_name"
  type        = string
}

variable "cluster_identifier" {
  description = "cluster_identifier"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "vpc_security_group_ids"
  type        = string
}