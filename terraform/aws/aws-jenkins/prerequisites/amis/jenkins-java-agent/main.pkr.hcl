packer {
  required_plugins {
    amazon = {
      version = "~> 1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "ami_name_prefix" {
  type    = string
  default = "jenkins-java-agent"
}

variable "ec2_instance_type" {
  type        = string
  description = "Instance type for EC2 deployments"
  default     = "t3.micro" # or "t4g.small"
}

variable "ec2_architecture" {
  type        = string
  description = "Instance type for EC2 deployments"
  default     = "x86_64" # or "arm64"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
  ami_name  = "${var.ami_name_prefix}-${var.ec2_architecture}-${local.timestamp}"
}

source "amazon-ebs" "main" {
  ami_name      = "${local.ami_name}"
  instance_type = var.ec2_instance_type
  region        = "${var.region}"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd-*/ubuntu-noble-24.04-*-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
      architecture        = var.ec2_architecture
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  subnet_filter {
    filters = {
      "tag:Tier" : "private"
    }
    most_free = true
    random    = false
  }
  ssh_username         = "ubuntu"
  ssh_interface        = "session_manager"
  communicator         = "ssh"
  iam_instance_profile = "SSM-EC2"
  user_data_file       = "jenkins-java-agent.cloud-init.yaml"
}

build {
  sources = ["source.amazon-ebs.main"]

  provisioner "shell" {
    inline = ["echo Building AMI: ${local.ami_name} on ${build.User}@${build.Host}", "echo 'Waiting for cloud-init'; while [ ! -f /var/lib/cloud/instance/boot-finished ]; do sleep 1; done; echo 'Done'"]
  }
}
