variable "user_name" {
  type = string
  description = "The name of the IAM user"
}

variable "redshift_integration_bucket_name" {
  description = "redshift destination bucket name"
  type        = string
}

variable "airbyte_s3_bucket" {
  description = "airbyte_s3_bucket"
  type = string
}