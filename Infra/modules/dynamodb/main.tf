resource "aws_dynamodb_table" "last_extraction_table" {
  name           = "last_extraction_table"
  billing_mode   = "PAY_PER_REQUEST"
  #read_capacity  = 20
  #write_capacity = 20
  hash_key       = "table_name"  # Partition key for each table

  attribute {
    name = "table_name"
    type = "S"
  }

}