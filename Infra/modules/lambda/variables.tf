variable "db_username" {
  description = "db_username"
  type        = string
  #default     = "XXXXX"
}

variable "db_password" {
  description = "db_password"
  type        = string
  #default     = "XXXXX"
}

variable "db_name" {
  description = "db_name"
  type        = string
  #default     = "XXXXX"
}

variable "aws_region" {
  description = "AWS Region to deploy to"
  type        = string
  #default = "eu-west-3"
}

variable "rds_endpoint" {
  description = "rds_endpoint"
  type        = string
  #default = "eu-west-3"
}

/*
variable "bucket_name" {
  description = "principal bucket name"
  type        = string
  #default     = "real-estate-etl-101"
}

# A VERIFIER : UTILITÉ
variable "raw_repertory" {
  description = "raws data repertory"
  type        = string
  #default     = "raw_data"
}
*/
variable "lambda_layer_arns" {
  description = "lambda_layer_arns"
  type        = list(string)
}

variable "runtime" {
  description = "Lambda Runtime"
  type        = string
}

variable "function_handler" {
  description = "Name of Lambda Function Handler"
  type        = string
}

variable "function_name" {
  description = "Name of Lambda Function"
  type        = string
}
/*
variable "path_to_source_file" {
  description = "Path to Lambda Fucntion Source Code"
  type        = string
}
*/
variable "path_to_source_folder" {
  description = "Path to Lambda Fucntion Source Code"
  type        = string
}

variable "path_to_output" {
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

variable "s3_bucket_arn" {
  description = "lambda_layer_arns"
  type        = string
}