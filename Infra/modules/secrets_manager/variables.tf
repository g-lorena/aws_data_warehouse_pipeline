variable "rds_secret_name" {
  description = "rds secret name"
  type        = string
}

variable "rds_secret_description" {
  description = "rds secret description"
  type        = string
  default     = "Secret stored for rds database credentials"
}

variable "redshift_secret_name" {
  description = "redshift secret name"
  type        = string
}

variable "redshift_secret_description" {
  description = "redshift secret description"
  type        = string
  default     = "Secret stored for redshift database credentials"
}

variable "rds_secret_values" {
  description = "The key-value pairs to store in the secret"
  type = map(string)
}