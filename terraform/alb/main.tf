provider "aws" {
  region  = "us-east-1"
}


# Define required providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">=0.14"
}

# This is to use Outputs from Dev Network Remote State 
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "finalproject-sarvesh"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}

# This is to use Outputs from Dev Webservers Remote State 
data "terraform_remote_state" "webservers" {
  backend = "s3"
  config = {
    bucket = "finalproject-sarvesh"
    key    = "webservers/terraform.tfstate"
    region = "us-east-1"
  }
}

module "alb" {
  source        = "../Modules/aws_alb"
  prefix        = var.prefix
  vpc_id        = data.terraform_remote_state.network.outputs.vpc_id
  subnet_ids    = data.terraform_remote_state.network.outputs.public_subnet_ids
  webserver_ids = data.terraform_remote_state.webservers.outputs.public_vm_ids
}
#TestingJosh