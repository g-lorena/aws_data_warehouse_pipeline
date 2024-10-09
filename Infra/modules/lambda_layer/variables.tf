variable "compatible_architectures" {
  description = "compatible_architectures"
  type        = list(string)
}

variable "compatible_layer_runtimes" {
  description = "compatible_layer_runtimes"
  type        = list(string)
}

variable "requirements_path"{
  description = "requirements path"
  type        = string
}

variable "layer_zip_path"{
  description = "layer zip path"
  type        = string
}

variable "lambda_layer_bucket_name"{
  description = "lambda layer bucket name"
  type        = string
}

variable "layer_name"{
  description = "layer name"
  type        = string
}

variable "lambda_layer"{
  description = "lambda layer"
  type        = string
}

/* 
variable "path_to_system_folder"{
  description = "path_to_system_folder"
  type        = string
}
*/
