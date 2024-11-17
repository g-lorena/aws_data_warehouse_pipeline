variable "postgres_db_password" {
  type        = string
  description = "password rds"
}

variable "postgres_db_name" {
  type        = string
  description = "db_name rds"
}

variable "postgres_host" {
  type        = string
  description = "host rds"
}

variable "postgres_db_username" {
  type        = string
  description = "db username"
}

variable "source_name" {
  type        = string
  description = "airbyte source name"
}
/*
variable "destination_name" {
  type        = string
  description = "airbyte destination name"
}
*/
variable "workspace_id" {
  type        = string
  description = "workspace id"
}
/*
variable "redshift_host" {
  type        = string
  description = "host rds"
}

variable "redshift_password" {
  type        = string
  description = "host password"
}

variable "redshift_database_name" {
  type        = string
  description = "host redshift name"
}

variable "redshift_database_username" {
  type        = string
  description = "username redshift name"
}

variable "airbyte_connection_name" {
  type = string
  description = "airbyte connection name "
}
*/
variable "ssh_key" {
  type = string
  description = "ssh_key"
}

variable "tunnel_host" {
  type = string
  description = "tunnel_host"
}

variable "tunnel_user" {
  type = string
  description = "tunnel_user"
}