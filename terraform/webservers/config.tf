terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.27"
    }
  }
  required_version = ">=0.14"
}

provider "aws" {
  region  = var.region
}

terraform {
  backend "s3" {
    bucket = "finalproject-sarvesh"
    key    = "webservers/terraform.tfstate"
    region = "us-east-1"
  }
}

#