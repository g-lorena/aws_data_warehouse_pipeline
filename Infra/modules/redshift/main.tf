data "aws_iam_policy_document" "redshift_assume_role" {
  statement {
  
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["redshift.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "redshift_policy" {
statement {
    effect    = "Allow"
    actions   = [
      "s3:GetObject", 
      "redshift:CopyFromS3",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:PutObject", 
      "redshift:DescribeClusters",
      "redshift:DescribeLoggingStatus",
      "redshift:EnableLogging",
      "redshift:DisableLogging"
      ]
    resources = ["*"]
  }

}

resource "aws_iam_role" "iam_for_redshift" {
  name               = "iam_for_redshift"
  assume_role_policy = data.aws_iam_policy_document.redshift_assume_role.json
}

resource "aws_iam_policy" "iam_policy_redshift" {
  name        = "redshift-policy"
  description = "allow redshift to get and list object into the bucket"
  policy      = data.aws_iam_policy_document.redshift_policy.json
}

resource "aws_iam_role_policy_attachment" "attach_lambda_policy_1" {
  role       = aws_iam_role.iam_for_redshift.name
  policy_arn = aws_iam_policy.iam_policy_redshift.arn
}
/*
resource "aws_redshift_parameter_group" "redshift_parameter_group" {
  name   = "parameter-group-test-terraform"
  family = "redshift-1.0"

  parameter {
    name  = "require_ssl"
    value = "true"
  }
}
*/
resource "aws_redshift_cluster" "my_healthcare_redshift" {
  cluster_identifier = var.cluster_identifier 
  database_name      = var.database_name 
  master_username    = var.master_username 
  master_password    = var.master_password 
  node_type          = var.node_type 
  cluster_type       = var.cluster_type
  availability_zone = var.availability_zone
  number_of_nodes         = 1
  publicly_accessible     = false
  iam_roles               = [aws_iam_role.iam_for_redshift.arn]
  vpc_security_group_ids  = [var.vpc_security_group_ids]
  skip_final_snapshot     = true
  cluster_subnet_group_name = var.cluster_subnet_group_name
  #cluster_parameter_group_name = aws_redshift_parameter_group.redshift_parameter_group.id
}