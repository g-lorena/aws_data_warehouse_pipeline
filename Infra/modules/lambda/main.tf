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
      "redshift:GetClusterCredentials",
      "redshift:DescribeClusters",
      "redshift:ExecuteStatement",
      "redshift:DescribeTable",
      "redshift-data:ExecuteStatement",
      "redshift-data:GetStatementResult"
    ]
    resources = ["*"]
  }
}
/*
data "aws_iam_policy_document" "lambda_policy_2" {
statement {
    effect    = "Allow"
    actions   = ["s3:GetObject","s3:ListBucket", "s3:PutObject", "rds:Connect", "ec2:CreateNetworkInterface","ec2:DeleteNetworkInterface", "ec2:AttachNetworkInterface", "ec2:DetachNetworkInterface", "ec2:DescribeNetworkInterfaces", "dynamodb:PutItem", "dynamodb:GetItem", ]
    resources = ["*"]
  }
}
*/
resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}
/*
resource "aws_iam_role" "iam_for_lambda_2" {
  name               = "iam_for_lambda_2"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_1.json
}
*/
resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda-policy_1"
  description = "allow lambda to get and list object into the bucket"
  policy      = data.aws_iam_policy_document.lambda_policy.json
}
/*
resource "aws_iam_policy" "lambda_policy_2" {
  name        = "lambda-policy_2"
  description = "allow lambda to get and list object into the bucket"
  policy      = data.aws_iam_policy_document.lambda_policy_2.json
}
*/
resource "aws_iam_role_policy_attachment" "attach_lambda_policy" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
/*
resource "aws_iam_role_policy_attachment" "attach_lambda_policy_2" {
  role       = aws_iam_role.iam_for_lambda_2.name
  policy_arn = aws_iam_policy.lambda_policy_2.arn
}
*/

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

data "archive_file" "lambda_3" {
  type        = "zip"
  source_dir = var.path_to_source_folder_3
  
  output_path = var.path_to_output_3
}

#source_file = var.path_to_source_file #"../../etl/extract/extract_data.py"
#"lambda_function_extract_data.zip"

# from rds to lambda


resource "aws_lambda_function" "lambda_1" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  #filename      = var.path_to_output #"lambda_function_extract_data.zip"
  filename = data.archive_file.lambda_1.output_path
  function_name = var.function_name_1 
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = var.function_handler_1 #"extract_data.lambda_handler"

  memory_size = var.memory_size
  timeout     = var.timeout

  source_code_hash = data.archive_file.lambda_1.output_base64sha256

  runtime = var.runtime #"python3.10"
  layers = var.lambda_layer_arns # à modifier

  vpc_config {
    subnet_ids = var.vpc_subnet_ids
    security_group_ids = [var.vpc_security_group_ids]
  }

  #s3_bucket = var.bucket_name
  #s3_key = aws_s3_object.lambda_layer_zip.key

  environment {
    variables = {
      DB_USERNAME = var.db_username
      DB_PASSWORD = var.db_password
      DB_NAME = var.db_name
      DB_HOST = var.rds_endpoint
     # REGION = var.aws_region
      DynamoDB_NAME = var.DynamoDB_table_name

      #RAW_FOLDER = var.raw_repertory
    }
  }
}


resource "aws_lambda_permission" "s3" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_1.arn
  principal     = "s3.amazonaws.com"

  source_arn = var.s3_bucket_arn
}


resource "aws_lambda_function" "lambda_2" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  #filename      = var.path_to_output #"lambda_function_extract_data.zip"
  filename = data.archive_file.lambda_2.output_path
  function_name = var.function_name_2 
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = var.function_handler_2 #"extract_data.lambda_handler"

  memory_size = var.memory_size
  timeout     = var.timeout

  source_code_hash = data.archive_file.lambda_2.output_base64sha256

  runtime = var.runtime #"python3.10"
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
      DynamoDB_NAME = var.DynamoDB_table_name
      DST_BUCKET = var.dst_bucket_name
      RAW_FOLDER = var.raw_repertory
    }
  }
}

resource "aws_lambda_permission" "s3_2" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_2.arn
  principal     = "s3.amazonaws.com"

  source_arn = var.s3_bucket_redshift_integration_arn
}

resource "aws_lambda_function" "lambda_3" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  #filename      = var.path_to_output #"lambda_function_extract_data.zip"
  filename = data.archive_file.lambda_3.output_path
  function_name = var.function_name_3 
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = var.function_handler_3 #"extract_data.lambda_handler"

  memory_size = var.memory_size
  timeout     = var.timeout

  source_code_hash = data.archive_file.lambda_3.output_base64sha256

  runtime = var.runtime #"python3.10"
  vpc_config {
    subnet_ids = var.vpc_subnet_ids
    security_group_ids = [var.vpc_security_group_ids]
  }

  environment {
    variables = {
      redshift_role_arn = var.redshift_role_arn
      DST_BUCKET = var.dst_bucket_name
      RAW_FOLDER = var.raw_repertory
    }
  }
}

resource "aws_lambda_permission" "s3_3" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_3.arn
  principal     = "s3.amazonaws.com"

  source_arn = var.s3_bucket_redshift_integration_arn
}
