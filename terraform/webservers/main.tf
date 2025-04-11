# ACS Final Project

# This is to use Outputs from Remote State
data "terraform_remote_state" "subnet_data" {
  backend = "s3"
  config = {
    bucket = "finalproject-sarvesh"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}

# Data source for AMI id
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}

# Define tags locally
locals {
  default_tags = var.default_tags
  name_prefix  = var.prefix
}

# Adding SSH  key to instance
resource "aws_key_pair" "keypair" {
  key_name   = "project_keypair"
  public_key = file("project_keypair.pub")
}

# Create Public Instance 
resource "aws_instance" "public_ec2" {
  count                       = length(data.terraform_remote_state.subnet_data.outputs.public_subnet_ids)
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.keypair.key_name
  security_groups             = [aws_security_group.public_webserver_sg.id]
  subnet_id                   = data.terraform_remote_state.subnet_data.outputs.public_subnet_ids[count.index]
  associate_public_ip_address = true
  user_data                   = count.index < 2 ? templatefile("${path.module}/install_httpd.sh.tpl", { prefix = upper(var.prefix) }) : ""
  lifecycle {
    create_before_destroy = true
  }
  tags = merge(local.default_tags,
    {
      "Name" = "${var.prefix}-WebServer-${count.index + 1}",
      "Build" = count.index < 2 ? "terraform" : "ansible"
    }
  )
}

#security Group
resource "aws_security_group" "public_webserver_sg" {
  name        = "public_webserver_sg"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = data.terraform_remote_state.subnet_data.outputs.vpc_id
  ingress {
    description      = "HTTP from everywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "SSH from everywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = merge(local.default_tags,
    {
      "Name" = "${var.prefix}-public_webserver_sg"
    }
  )
}

resource "aws_instance" "private_ec2" {
  count                       = length(data.terraform_remote_state.subnet_data.outputs.private_subnet_ids)
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.keypair.key_name
  security_groups             = count.index == 0 ? [aws_security_group.private_webserver_sg.id] : [aws_security_group.private_vm_sg.id]
  subnet_id                   = data.terraform_remote_state.subnet_data.outputs.private_subnet_ids[count.index]
  associate_public_ip_address = false
  user_data                   = count.index == 0 ? templatefile("${path.module}/install_httpd.sh.tpl", { prefix = upper(var.prefix) }) : ""
  lifecycle {
    create_before_destroy = true
  }
  tags = count.index == 0 ? { Name = "${var.prefix}-WebServer-5" } : { Name = "${var.prefix}-VM" }
}

#security Group
resource "aws_security_group" "private_webserver_sg" {
  name        = "allow_http_and_ssh_only_for_admins"
  description = "Allow HTTP and SSH inbound traffic only for Admins"
  vpc_id      = data.terraform_remote_state.subnet_data.outputs.vpc_id
  ingress {
    description      = "HTTP from specific IP addresses"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = [aws_security_group.public_webserver_sg.id]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "SSH from specific IP addresses"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups  = [aws_security_group.public_webserver_sg.id]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = merge(local.default_tags,
    {
      "Name" = "${var.prefix}-private_webserver_sg"
    }
  )
}

resource "aws_security_group" "private_vm_sg" {
  name        = "allow_ssh_only_for_admins"
  description = "Allow SSH inbound traffic only for Admins"
  vpc_id      = data.terraform_remote_state.subnet_data.outputs.vpc_id
  ingress {
    description      = "SSH from specific IP addresses"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups  = [aws_security_group.public_webserver_sg.id]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = merge(local.default_tags,
    {
      "Name" = "${var.prefix}-private_vm_sg"
    }
  )
}