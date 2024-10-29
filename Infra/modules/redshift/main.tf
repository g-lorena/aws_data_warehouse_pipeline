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

resource "aws_redshift_cluster" "my_healthcare_redshift" {
  cluster_identifier = var.cluster_identifier #"my_healthcare_redshift_cluster"
  database_name      = var.database_name #"my_healthcare_datawarehouse"
  master_username    = var.master_username #"exampleuser"
  master_password    = var.master_password #"Mustbe8characters"
  node_type          = var.node_type #"dc1.large"
  cluster_type       = var.cluster_type#"single-node"
  number_of_nodes         = 1
  publicly_accessible     = true
  iam_roles               = [aws_iam_role.iam_for_redshift.arn]
  vpc_security_group_ids  = [var.vpc_security_group_ids]
  skip_final_snapshot     = true
  cluster_subnet_group_name = var.cluster_subnet_group_name

}

resource "null_resource" "init_redshift_tables" {
  provisioner "local-exec" {
    command = <<EOT
    psql -h ${aws_redshift_cluster.my_healthcare_redshift.endpoint} \
    -U ${aws_redshift_cluster.my_healthcare_redshift.master_username} \
    -d ${aws_redshift_cluster.my_healthcare_redshift.database_name} \
    -f ./sql/create_tables.sql
    EOT
    environment = {
      PGPASSWORD = aws_redshift_cluster.my_healthcare_redshift.master_password
    }
  }
  depends_on = [aws_redshift_cluster.my_healthcare_redshift]
}