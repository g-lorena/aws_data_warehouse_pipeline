locals{

  # bucket 
  lambda_layer_bucket_name = "my-lambda-layer-bucket-00113"
  lambda_layer             = "lambda_layer"
  bucket_name = "my-project-test-101"

  redshift_integration_bucket_name = "my-redshift-integration-bucket-001"
  raw_repertory            = "raw_data"
  
   # cloudwatch
  #schedule_name  = "schedule rds" # "schedule extraction"]
  #schedule_value = "cron(0 8 ? * MON-FRI *)" #, "cron(0 8 ? * MON-FRI *)"] 

  # lambda layer
  layer_zip_path    = "python.zip"
  layer_name        = "my_lambda_requirements_layer"
  requirements_path = "../requirements.txt"

  compatible_layer_runtimes = ["python3.9"]
  compatible_architectures  = ["x86_64"] 

  # lambda function 1
  path_to_source_folder = "../lambda_rds"
  #path_to_source_file = "../etl/extract"
  path_to_output   = "lambda_rds.zip"
  function_name_1    = "rds_ingestion"
  function_handler_1 = "rds_ingestion.lambda_handler"
  memory_size      = 512
  timeout          = 300
  runtime          = "python3.9"
  aws_region = "eu-west-3"

  # lambda function 2
  path_to_source_folder_2 = "../lambda_to_s3"
  path_to_output_2 = "lambda_to_s3.zip"
  function_name_2 = "rds_to_s3"
  function_handler_2 = "rds_to_s3.lambda_handler"

  # lambda function 3
  path_to_source_folder_3 = "../lambda_to_redshift"
  path_to_output_3 = "load_to_redshift.zip"
  function_name_3 = "load_to_redshift"
  function_handler_3 = "load_to_redshift.lambda_handler"
  
  #rds
  db_username = "lorena"
  db_password = "YourStrongPass12345!"
  db_name = "medical_database"

  #redshift
  cluster_identifier = "my-healthcare-redshift-cluster"
  database_name = "my_healthcare_datawarehouse"
  master_username = "exampleuser"
  master_password = "Mustbe8characters"
  node_type = "dc2.large"
  cluster_type = "single-node"

}