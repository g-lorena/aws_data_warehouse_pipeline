terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 5.0.0" #4.0 4.67.0
      }
      airbyte = {
        source = "airbytehq/airbyte"
        version = "0.6.5"
      }
        null = {
        source = "hashicorp/null"
        version = "3.2.3"
      }
    }
}

provider "aws" {}

provider "null" {
  # Configuration options
}

provider "airbyte"{
  client_id = var.client_id
  client_secret = var.client_secret
  bearer_auth = var.api_key
  #server_url = var.server_url
}