# Variable to signal the current environment 
variable "region" {
  default     = "us-east-1"
  type        = string
  description = "AWS Region"
}

variable "profile" {
  default     = "default"
  type        = string
  description = "AWS Profile"
}

# Instance type
variable "instance_type" {
  default     = "t2.micro"
  type        = string
  description = "Type of the instance"
}

# Default tags
variable "default_tags" {
  default = {
    "Owner" = "Sarvesh nagar"
    "App"   = "Web"
  }
  type        = map(any)
  description = "Default tags to be appliad to all AWS resources"
}

# Name prefix
variable "prefix" {
  default     = "project"
  type        = string
  description = "Name Prefix"
}

# Variable for the github repository
#variable "github_repo" {
 # default     = ""
  #type        = string
  #description = "Github Repo Link"
#}
