terraform {
  backend "s3" {
    bucket = "finalproject-sarvesh"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}
#testing by rohit 