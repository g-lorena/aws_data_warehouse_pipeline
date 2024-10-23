# create zip file from requirements.txt. Triggers only when the file is updated
# first method 
resource "null_resource" "lambda_layer" {
  triggers = {
    requirements = filesha1(var.requirements_path)
  }
  # the command to install python and dependencies to the machine and zips
  provisioner "local-exec" {
    command = <<EOT
      set -e
      rm -rf python venv_layer
      mkdir python
      python3 -m venv venv_layer
      . venv_layer/bin/activate 
      python3 -m pip install --upgrade pip
      pip3 install --no-cache-dir -r ${var.requirements_path}
      cp -r venv_layer/lib/python*/site-packages/* python
      zip -r ${var.layer_zip_path} python/
      rm -rf venv_layer
      rm -rf python
    EOT
  }
}

resource "aws_s3_bucket" "lambda_layer_bucket" {
  bucket = var.lambda_layer_bucket_name
}

resource "aws_s3_object" "lambda_layer_zip" {
    bucket   = aws_s3_bucket.lambda_layer_bucket.id
    key      =  "${var.lambda_layer}/${var.layer_name}/${var.layer_zip_path}"
    source     = var.layer_zip_path
    depends_on = [null_resource.lambda_layer] # triggered only if the zip file is created
    #content_type = "application/x-directory"  
}

resource "aws_lambda_layer_version" "requests_layer" {
  s3_bucket   = aws_s3_bucket.lambda_layer_bucket.id
  s3_key = aws_s3_object.lambda_layer_zip.key
  layer_name = var.layer_name
  #source_code_hash    = filebase64sha256(var.path_to_request_layer_filename)

  compatible_runtimes      = var.compatible_layer_runtimes
  depends_on = [aws_s3_object.lambda_layer_zip]
  compatible_architectures = var.compatible_architectures

}