resource "aws_ecr_repository" "dbt_repository" {
  name                 = "healthcare-dbt-project"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}