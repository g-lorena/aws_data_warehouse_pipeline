output "s3_bucket_arn"{
    value = aws_s3_bucket.bucket.arn
}

output "s3_bucket_redshift_integration_arn" {
  value = aws_s3_bucket.redshift_integration_bucket.arn
}

output "aws_s3_bucket_uri" {
  value = "${aws_s3_bucket.redshift_integration_bucket.bucket}/${aws_s3_object.raw_zone.key}"
}