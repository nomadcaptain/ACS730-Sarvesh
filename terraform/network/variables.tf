variable "profile" {
  default     = "default"
  type        = string
  description = "AWS Profile"
}

variable "region" {
  default     = "us-east-1"
  type        = string
  description = "AWS Region"
}

# Variable to signal the current environment 
variable "env" {
  default     = "dev"
  type        = string
  description = "Deployment Environment"
}

# VPC CIDR range
variable "vpc_cidr" {
  default     = "10.1.0.0/16"
  type        = string
  description = "VPC to host static web site"
}

# Provision public subnets in custom VPC
variable "public_subnet_cidrs" {
  default     = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24", "10.1.4.0/24"]
  type        = list(string)
  description = "Public Subnet CIDRs"
}

# Provision private subnets in custom VPC
variable "private_subnet_cidrs" {
  default     = ["10.1.5.0/24", "10.1.6.0/24"]
  type        = list(string)
  description = "Private Subnet CIDRs"
}

# Name prefix
variable "prefix" {
  default     = "project"
  type        = string
  description = "Name Prefix"
}

# Default tags
variable "default_tags" {
  default = {
    "Owner" = "Sarvesh nagar",
  }
  type        = map(any)
  description = "Default tags to be appliad to all AWS resources"
}