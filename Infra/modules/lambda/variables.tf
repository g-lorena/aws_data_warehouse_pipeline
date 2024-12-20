variable "db_username" {
  description = "db_username"
  type        = string
}

variable "db_password" {
  description = "db_password"
  type        = string
}

variable "db_name" {
  description = "db_name"
  type        = string
}

variable "rds_endpoint" {
  description = "rds_endpoint"
  type        = string
}

variable "lambda_layer_arns" {
  description = "lambda_layer_arns"
  type        = list(string)
}

variable "runtime" {
  description = "Lambda Runtime"
  type        = string
}

variable "function_handler_1" {
  description = "Name of Lambda Function Handler"
  type        = string
}

variable "function_handler_2" {
  description = "Name of Lambda Function Handler"
  type        = string
}

variable "function_name_1" {
  description = "Name of Lambda Function"
  type        = string
}

variable "function_name_2" {
  description = "Name of Lambda Function"
  type        = string
}

variable "path_to_source_folder" {
  description = "Path to Lambda Fucntion Source Code"
  type        = string
}

variable "path_to_source_folder_2" {
  description = "Path to Lambda Fucntion Source Code"
  type        = string
}

variable "path_to_output" {
  description = "Path to ZIP artifact"
  type        = string
}

variable "path_to_output_2" {
  description = "Path to ZIP artifact"
  type        = string
}

variable "memory_size" {
  description = "Lambda Memory"
  type        = number
}

variable "timeout" {
  description = "Lambda Timeout"
  type        = number
}

variable "raw_repertory" {
  description = "raw_repertory"
  type = string
}

variable "vpc_subnet_ids" {
  description = "vpc_subnet_ids"
  type        = list(string)
}

variable "vpc_security_group_ids" {
  description = "vpc_security_group_ids"
  type        = string
}

variable "dst_bucket_name" {
  description = "DynamoDB_table_name"
  type        = string
}