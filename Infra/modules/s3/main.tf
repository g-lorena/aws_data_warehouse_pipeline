resource "aws_iam_user" "airbyte_user" {
  name = "airbyte-user"
}

data "aws_iam_policy_document" "airbyte_user_document" {
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject", "s3:GetObject", "s3:ListBucket", "s3:DeleteObject"]
    resources = [
      "arn:aws:s3:::${var.redshift_integration_bucket_name}/*",
      "arn:aws:s3:::${var.redshift_integration_bucket_name}",
      "arn:aws:s3:::${var.airbyte_s3_bucket}/*",
      "arn:aws:s3:::${var.airbyte_s3_bucket}"
    ]
  }
}

resource "aws_iam_user_policy" "airbyte_user_policy" {
  name   = "airbyte-s3-access"
  user   = aws_iam_user.airbyte_user.name
  policy = data.aws_iam_policy_document.airbyte_user_document.json
}

resource "aws_iam_access_key" "airbyte_access_key" {
  user = aws_iam_user.airbyte_user.name

  # Sensitive outputs are written to a file for security
  #lifecycle {
  #  prevent_destroy = true # Prevent accidental deletion
  #}
}

resource "aws_s3_bucket" "bucket"{
  bucket  = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket" "airbyte_staging" {
  bucket = var.airbyte_s3_bucket #"airbyte-staging-bucket"
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