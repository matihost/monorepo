variable "region" {
  type    = string
  default = "us-east-1"
}

variable "ami_name_prefix" {
  type    = string
  default = "jenkins-master"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
  ami_name  = "${var.ami_name_prefix}-${local.timestamp}"
}

source "amazon-ebs" "main" {
  ami_name      = "${local.ami_name}"
  instance_type = "t4g.small"
  region        = "${var.region}"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd-*/ubuntu-noble-24.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username   = "ubuntu"
  user_data_file = "jenkins-master.cloud-init.yaml"
}

build {
  sources = ["source.amazon-ebs.main"]

  provisioner "shell" {
    inline = ["echo Building AMI: ${local.ami_name} on ${build.User}@${build.Host}", "echo 'Waiting for cloud-init'; while [ ! -f /var/lib/cloud/instance/boot-finished ]; do sleep 1; done; echo 'Done'",
    "echo `whoami`"]
  }
  provisioner "shell" {
    scripts = ["jenkins-master.buildout.sh"]
  }
}
