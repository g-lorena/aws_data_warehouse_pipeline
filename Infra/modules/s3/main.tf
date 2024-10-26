resource "aws_s3_bucket" "bucket"{
  bucket  = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket" "redshift_integration_bucket" {
  bucket  = var.redshift_integration_bucket_name
  force_destroy = true
}

resource "aws_s3_object" "raw_zone" {
    bucket   = aws_s3_bucket.redshift_integration_bucket.id
    acl = "private"
    key      =  "${var.raw_repertory}/"
    content_type = "application/x-directory"  
}