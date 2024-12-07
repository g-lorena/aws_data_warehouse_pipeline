output "s3_bucket_arn"{
    value = aws_s3_bucket.bucket.arn
}

output "s3_bucket_redshift_integration_arn" {
  value = aws_s3_bucket.redshift_integration_bucket.arn
}

output "aws_s3_bucket_uri" {
  value = "${aws_s3_bucket.redshift_integration_bucket.bucket}/${aws_s3_object.raw_zone.key}"
}

output "s3_bucket_redshift_integration_id" {
  value = aws_s3_bucket.redshift_integration_bucket.id
}

output "s3_bucket_redshift_integration_bucket" {
  value = aws_s3_bucket.redshift_integration_bucket.bucket
}

output "airbyte_s3_bucket_output" {
  value = aws_s3_bucket.airbyte_staging.bucket
}

output "access_key_id" {
  value       = aws_iam_access_key.airbyte_access_key.id
  description = "The AWS Access Key ID for the Airbyte user"
  sensitive   = true
}

output "secret_access_key" {
  value       = aws_iam_access_key.airbyte_access_key.secret
  description = "The AWS Secret Access Key for the Airbyte user"
  sensitive   = true
}