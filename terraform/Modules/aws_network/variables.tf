variable "profile" {
  # default     = "default"
  type        = string
  description = "AWS Profile"
}

variable "region" {
  # default     = "us-east-1"
  type        = string
  description = "AWS Region"
}

# VPC CIDR range
variable "vpc_cidr" {
  # default     = "10.20.0.0/16"
  type        = string
  description = "VPC to host static web site"
}

# Provision public subnets in custom VPC
variable "public_subnet_cidrs" {
  # default     = ["10.20.0.0/24", "10.20.1.0/24"]
  type        = list(string)
  description = "Public Subnet CIDRs"
}

# Provision private subnets in custom VPC
variable "private_subnet_cidrs" {
  # default     = ["10.20.0.0/24", "10.20.1.0/24"]
  type        = list(string)
  description = "Public Subnet CIDRs"
}

# Prefix to identify resources
variable "prefix" {
  # default     = "Lab4-2"
  type        = string
  description = "Name prefix"
}

# Default tags
variable "default_tags" {
  # default = {
  #   "Owner" = "Amaan"
  #   "App"   = "Web"
  # }
  type        = map(any)
  description = "Default tags to be appliad to all AWS resources"
}

# Variable to signal the current environment 
variable "env" {
  # default     = "dev"
  type        = string
  description = "Deployment Environment"
}