variable "bucket_name" { # bucket with layers
  description = "principal bucket name"
  type        = string
  #default     = "real-estate-etl-101"
}

variable "redshift_integration_bucket_name" {
  description = "redshift destination bucket name"
  type        = string
  #default     = "real-estate-etl-101"
}

variable "raw_repertory" {
  description = "raw data repertory"
  type        = string
}
variable "airbyte_workspace_id" {
  description = "airbyte_workspace_id"
  type = string
}
variable "airbyte_s3_bucket" {
  description = "airbyte_s3_bucket"
  type = string
}