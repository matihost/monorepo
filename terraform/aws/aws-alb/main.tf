provider "aws" {
  profile = "default"
  region  = var.region
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "private_subnet" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = var.zone
  tags = {
    Tier = "private"
  }
}


data "aws_subnet" "public_subnet_1" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = var.zone
  default_for_az    = true
}

data "aws_subnet" "public_subnet_2" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "us-east-1b"
  default_for_az    = true
}

data "aws_security_group" "internal_access" {
  tags = {
    Name = "internal_access"
  }
}



variable "zone" {
  default     = "us-east-1a"
  description = "Preffered AWS AZ where resources need to placed, has to be compatible with region variable"
}

variable "region" {
  default     = "us-east-1"
  description = "Preffered AWS region where resource need to be placed"
}


variable "external_access_ip" {
  type        = string
  description = "The public IP which is allowed to access instance"
}

variable "instance_profile" {
  default     = ""
  type        = string
  description = "The name of instance_profile (dynamically provisioning access to role)"
}
