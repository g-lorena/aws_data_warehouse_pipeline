data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
  
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "lambda_policy" {
statement {
    effect    = "Allow"
    actions   = [
      "s3:GetObject",
      "s3:ListBucket", 
      "s3:PutObject", 
      "rds:Connect",
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface", 
      "ec2:AttachNetworkInterface", 
      "ec2:DetachNetworkInterface", 
      "ec2:DescribeNetworkInterfaces", 
      "dynamodb:PutItem", 
      "dynamodb:GetItem",
      "dynamodb:UpdateItem",
      "redshift:GetClusterCredentials",
      "redshift:DescribeClusters",
      "redshift:ExecuteStatement",
      "redshift:DescribeTable",
      "redshift-data:ExecuteStatement",
      "redshift-data:GetStatementResult",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda-policy_1"
  description = "allow lambda to get and list object into the bucket"
  policy      = data.aws_iam_policy_document.lambda_policy.json
}

resource "aws_iam_role_policy_attachment" "attach_lambda_policy" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

data "archive_file" "lambda_1" {
  type        = "zip"
  source_dir = var.path_to_source_folder
  
  output_path = var.path_to_output 
}

data "archive_file" "lambda_2" {
  type        = "zip"
  source_dir = var.path_to_source_folder_2
  
  output_path = var.path_to_output_2
}

resource "aws_lambda_function" "lambda_1" {
  filename = data.archive_file.lambda_1.output_path
  function_name = var.function_name_1 
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = var.function_handler_1 

  memory_size = var.memory_size
  timeout     = var.timeout

  source_code_hash = data.archive_file.lambda_1.output_base64sha256

  runtime = var.runtime 
  layers = var.lambda_layer_arns 

  vpc_config {
    subnet_ids = var.vpc_subnet_ids
    security_group_ids = [var.vpc_security_group_ids]
  }

  environment {
    variables = {
      DB_USERNAME = var.db_username
      DB_PASSWORD = var.db_password
      DB_NAME = var.db_name
      DB_HOST = var.rds_endpoint
      DST_BUCKET = var.dst_bucket_name
      RAW_FOLDER = var.raw_repertory
    }
  }
  
}

resource "aws_lambda_function" "lambda_2" {
  filename = data.archive_file.lambda_2.output_path
  function_name = var.function_name_2 
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = var.function_handler_2 

  memory_size = var.memory_size
  timeout     = var.timeout

  source_code_hash = data.archive_file.lambda_2.output_base64sha256

  runtime = var.runtime 
 
  vpc_config {
    subnet_ids = var.vpc_subnet_ids
    security_group_ids = [var.vpc_security_group_ids]
  }

  environment {
    variables = {
      DST_BUCKET = var.dst_bucket_name
      RAW_FOLDER = var.raw_repertory
    }
  }
  
}