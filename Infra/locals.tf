locals{

  # bucket 
  lambda_layer_bucket_name = "my-lambda-layer-bucket-00113"
  lambda_layer             = "lambda_layer"
  bucket_name = "my-project-test-101"

   # cloudwatch
  schedule_name  = "schedule"
  schedule_value = "cron(0 8 ? * MON-FRI *)" 

  # lambda layer
  layer_zip_path    = "python.zip"
  layer_name        = "my_lambda_requirements_layer"
  requirements_path = "../requirements.txt"

  compatible_layer_runtimes = ["python3.10"]
  compatible_architectures  = ["x86_64"] 

  # lambda 
  path_to_source_folder = "../lambda_functions"
  #path_to_source_file = "../etl/extract"
  path_to_output   = "lambda_function_extract_data.zip"
  function_name    = "rds_to_redshift"
  function_handler = "rds_to_redshift.lambda_handler"
  memory_size      = 512
  timeout          = 300
  runtime          = "python3.10"
  aws_region = "eu-west-3"

  #rds
  db_username = "lorena"
  db_password = "YourStrongPass12345!"
  db_name = "medical_database"


}