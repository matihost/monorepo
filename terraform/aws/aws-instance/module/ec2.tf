data "aws_vpc" "default" {
  default = var.vpc == "default" ? true : null

  tags = var.vpc == "default" ? null : {
    Name = var.vpc
  }
}

data "aws_subnet" "public_zone" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = var.zone

  default_for_az = var.subnet == "default" ? true : null

  tags = var.subnet == "default" ? null : {
    Tier = var.subnet
  }

}

resource "aws_security_group" "private_access" {
  name        = "${local.prefix}-${var.region}-${var.name}"
  description = "Allow HTTP access from single computer or VPC and opens SSH"

  vpc_id = data.aws_vpc.default.id

  tags = {
    Name = "private_access"
  }

  ingress {
    description = "HTTP from laptop or from within VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.external_access_range, data.aws_vpc.default.cidr_block]
  }
  ingress {
    description = "HTTP 8080 from laptop or from within VPC"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.external_access_range, data.aws_vpc.default.cidr_block]
  }
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Terraform removed default egress ALLOW_ALL rule
  # It has to be explicitely added
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_key_pair" "vm_key" {
  key_name   = "${local.prefix}-${var.region}-${var.name}"
  public_key = var.ssh_pub_key
}


data "aws_ami" "image" {
  most_recent = true

  # possible filter ids from sample image:
  # aws ec2 describe-images --region us-east-1 --image-ids ami-0fc5d935ebf8bc3bc
  filter {
    name   = "name"
    values = [var.ec2_ami_name_query]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = [var.ec2_architecture]
  }

  owners = [var.ec2_ami_account]
}


resource "aws_instance" "vm" {
  ami                    = data.aws_ami.image.id
  instance_type          = var.ec2_instance_type
  key_name               = aws_key_pair.vm_key.key_name
  vpc_security_group_ids = [aws_security_group.private_access.id]
  subnet_id              = data.aws_subnet.public_zone.id

  iam_instance_profile = var.instance_profile
  # to use cloud-init and bash script
  # use https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config
  user_data = templatestring(var.user_data_template, {
    ssh_key = base64encode(var.ssh_key),
    ssh_pub = base64encode(var.ssh_pub_key),
    }
  )
  tags = {
    Name = "${local.prefix}-${var.region}-${var.name}"
  }

  # connection {
  #   type        = "ssh"
  #   user        = "ubuntu" # Ubuntu AMI has ubuntu user name instead of ec2-user
  #   private_key = var.ssh_key
  #   host        = self.public_ip
  # }

  # demonstrate provisioner usage
  # use user_data and script or cloud-init config instead
  # provisioner "remote-exec" {
  #   inline = [
  #     "sudo apt -y install plocate",
  #   ]
  # }
}


output "ec2_id" {
  value = aws_instance.vm.id
}

output "ec2_ip" {
  value = aws_instance.vm.public_ip
}

output "ec2_dns" {
  value = aws_instance.vm.public_dns
}

output "ec2_private_dns" {
  value = aws_instance.vm.private_dns
}

output "ec2_user_data" {
  description = "Instance user_data (aka init config)"
  value       = format("aws ec2 describe-instance-attribute --instance-id %s --attribute userData --output text --query \"UserData.Value\" | base64 --decode", aws_instance.vm.id)
}
