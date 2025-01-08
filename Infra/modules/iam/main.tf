resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_iam_user" "airbyte_user" {
  name = "airbyte-user-${random_id.suffix.hex}" #var.user_name
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
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
  
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.iam_for_ec2.name
  
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ec2_s3_policy_document" {
statement {
    effect    = "Allow"
    actions   = [
      "s3:PutObject", 
      "s3:GetObject", 
      "s3:ListBucket", 
      "s3:DeleteObject", 
     # "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ]
    resources = [
      "arn:aws:s3:::${var.dbt_project_bucket}/*",
      "arn:aws:s3:::${var.dbt_project_bucket}",
      "arn:aws:ecr:eu-west-3:${data.aws_caller_identity.current.account_id}:repository/healthcare-dbt-project"
    ]
  }
statement {
  effect = "Allow"
  actions = [ "ecr:GetAuthorizationToken" ]
  resources = [
      "*"
    ]
}
}

resource "aws_iam_role" "iam_for_ec2" {
  name               = "iam_for_ec2_s3"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_policy" "iam_policy" {
  name        = "ec2-s3-policy"
  description = "allow ec2 to get and list object into the bucket"
  policy      = data.aws_iam_policy_document.ec2_s3_policy_document.json
}

resource "aws_iam_role_policy_attachment" "attach_ec2_policy" {
  role       = aws_iam_role.iam_for_ec2.name 
  policy_arn = aws_iam_policy.iam_policy.arn
}