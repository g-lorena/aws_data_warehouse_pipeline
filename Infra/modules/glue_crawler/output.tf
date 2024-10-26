output "aws_glue_my_healthcare_crawler_name" {
  value = aws_glue_crawler.my_healthcare_crawler.name
  description = "The name of the Glue Crawler"
}