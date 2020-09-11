provider "aws" {
  profile = "default"
  region  = var.region
}

resource "aws_key_pair" "vm_key" {
  key_name   = "vm"
  public_key = file("~/.ssh/id_rsa.aws.vm.pub")
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


variable "create_sample_instance" {
  type        = bool
  default     = false
  description = "Whether to span single instance in private subnet"
}
