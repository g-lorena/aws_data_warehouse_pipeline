output "last_extraction_table_name" {
  value = aws_dynamodb_table.last_extraction_table.name
  description = "the name of the DynamoDB table"
}