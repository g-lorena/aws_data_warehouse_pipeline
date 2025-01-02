variable "bucket_name" {
  description = "principal bucket name"
  type        = string
}

variable "raw_repertory" {
  description = "raw data repertory"
  type        = string
}

variable "airbyte_workspace_id" {
  description = "airbyte_workspace_id"
  type = string
}

variable "redshift_integration_bucket_name" {
  description = "redshift destination bucket name"
  type        = string
}

variable "airbyte_s3_bucket" {
  description = "airbyte_s3_bucket"
  type = string
}

variable "dbt_project_bucket_name" {
  description = "dbt_project_bucket_name"
  type = string
}