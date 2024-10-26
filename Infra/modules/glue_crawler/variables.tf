variable "glue_iam_role" {
  description = "glue iam role"
  type        = string
}

variable "database" {
  description = "glue catalog database name"
  type        = string
}

variable "tables" {
  description = "List of tables"
  type        = list(string)
  #default     = ["patients", "treatments", "doctors", "appointment", "medication"]
}