
module "vpc" {
  source = "./modules/vpc"
  
}

module "s3bucket" {
  source = "./modules/s3"

  bucket_name   = local.bucket_name
  redshift_integration_bucket_name = local.redshift_integration_bucket_name
  raw_repertory = local.raw_repertory

}

module "dynamodb" {
  source = "./modules/dynamodb"
}

module "rds" {
  source      = "./modules/rds"
  db_username = local.db_username
  db_password = local.db_password
  db_name     = local.db_name
  db_subnet_group_name = module.vpc.database_subnet_group_name
  availability_zone = module.vpc.availability_zone_name
  vpc_security_group_ids = module.vpc.database_security_group_id

}

module "lambdaLayer" {
  source = "./modules/lambda_layer"

  requirements_path = local.requirements_path
  layer_zip_path    = local.layer_zip_path
  layer_name        = local.layer_name

  #path_to_system_folder = local.path_to_system_folder

  lambda_layer_bucket_name = local.lambda_layer_bucket_name
  lambda_layer             = local.lambda_layer

  compatible_layer_runtimes = local.compatible_layer_runtimes
  compatible_architectures  = local.compatible_architectures

}

module "lambdaFunction" {
  source = "./modules/lambda"

  path_to_source_folder = local.path_to_source_folder
  path_to_output        = local.path_to_output
  function_name_1         = local.function_name_1
  function_handler_1      = local.function_handler_1

  memory_size           = local.memory_size
  timeout               = local.timeout
  runtime               = local.runtime

  db_username       = local.db_username
  db_password       = local.db_password
  db_name           = local.db_name
  rds_endpoint      = module.rds.rds_host
  DynamoDB_table_name = module.dynamodb.last_extraction_table_name
  #raw_repertory     = local.raw_repertory
  
  aws_region        = local.aws_region
  s3_bucket_arn         = module.s3bucket.s3_bucket_arn

  vpc_subnet_ids = module.vpc.subnet_ids
  vpc_security_group_ids = module.vpc.lambda_security_group_id
  lambda_layer_arns = [module.lambdaLayer.lamnda_layer_arn]


  # ------

  path_to_source_folder_2 = local.path_to_source_folder_2
  path_to_output_2 = local.path_to_output_2
  function_name_2 = local.function_name_2
  function_handler_2 = local.function_handler_2
  dst_bucket_name = local.redshift_integration_bucket_name
  raw_repertory = local.raw_repertory
  s3_bucket_redshift_integration_arn = module.s3bucket.s3_bucket_redshift_integration_arn

  path_to_source_folder_3 = local.path_to_source_folder_3
  path_to_output_3 = local.path_to_output_3
  function_name_3 = local.function_name_3
  function_handler_3 = local.function_handler_3
  REDSHIFT_ROLE_ARN = module.redshift.redshift_role_arn

  redshift_integration_bucket_id = module.s3bucket.s3_bucket_redshift_integration_id

  REDSHIFT_DB = local.database_name
  REDSHIFT_USER = local.master_username
  REDSHIFT_PASSWORD = local.master_password
  REDSHIFT_HOST = module.redshift.redshift_hostname
  aws_redshift_cluster_endpoint = module.redshift.redshift_endpoint

  bucket_id = module.s3bucket.s3_bucket_redshift_integration_id

}

module "redshift" {
  source                   = "./modules/redshift"
  cluster_identifier = local.cluster_identifier
  database_name = local.database_name
  master_username = local.master_username
  master_password = local.master_password
  node_type = local.node_type
  cluster_type = local.cluster_type
  vpc_security_group_ids = module.vpc.redshift_sg_id
  cluster_subnet_group_name = module.vpc.aws_redshift_subnet_group_name

}

module "cloudwatch_schedule_module_lambda1" {
  source                   = "./modules/eventbridge"
  schedule_name            = "trigger_every_1_hour"
  schedule_value           = "cron(0 * * * ? *)"
  aws_lambda_arn           = module.lambdaFunction.lambda1_function_arn 
  aws_lambda_function_name = module.lambdaFunction.lambda1_function_name 
}

module "cloudwatch_schedule_module_lambda2" {
  source                   = "./modules/eventbridge"
  schedule_name            = "trigger_daily"
  schedule_value           = "cron(0 0 * * ? *)"
  aws_lambda_arn           = module.lambdaFunction.lambda2_function_arn
  aws_lambda_function_name = module.lambdaFunction.lambda2_function_name
}
