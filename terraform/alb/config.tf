terraform {
  backend "s3" {
    bucket = "finalproject-sarvesh"
    key    = "alb/terraform.tfstate"
    region = "us-east-1"
  }
}
# Action Test