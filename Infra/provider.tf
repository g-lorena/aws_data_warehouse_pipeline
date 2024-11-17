terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 4.0"
      }
      airbyte = {
        source = "airbytehq/airbyte"
        version = "0.6.5"
      }
    }
}

provider "aws" {}

provider "airbyte"{
  client_id = var.client_id
  client_secret = var.client_secret
  bearer_auth = var.api_key
  #server_url = var.server_url
}