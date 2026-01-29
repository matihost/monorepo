

# Install only one AWS agent per combination of AWS account and AWS region.
# Installing multiple AWS agents for the same combination of AWS account and AWS region can incur extra costs from AWS, without added benefit in terms of quality of monitoring by using Instana.

resource "aws_security_group" "instana" {
  name        = "${local.prefix}-agent"
  description = "Allow only SSH/RDP access"

  vpc_id = data.aws_vpc.vpc.id

  tags = {
    Name = "${local.prefix}-agent"
  }

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "RDP from anywhere"
    from_port   = 3389
    to_port     = 3389
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

  # "most_recent" is set to "true" and results are not filtered by owner or
  # image ID. With this configuration, a third party may introduce a new image
  # which will be returned by this data source. Filter by owner or image ID to
  # avoid this possibility.
  allow_unsafe_filter = true # it is safe when search is by owner-alias or owners

  dynamic "filter" {
    for_each = var.ec2_ami_account_alias != "" ? [1] : []
    content {
      name   = "owner-alias"
      values = [var.ec2_ami_account_alias]
    }
  }

  owners = var.ec2_ami_account != "" ? [var.ec2_ami_account] : null
}


resource "aws_instance" "instana" {
  ami                    = data.aws_ami.image.id
  instance_type          = var.ec2_instance_type
  key_name               = aws_key_pair.vm_key.key_name
  vpc_security_group_ids = [aws_security_group.instana.id]
  subnet_id              = data.aws_subnet.private[var.zone].id
  iam_instance_profile   = aws_iam_instance_profile.instana.name
  # to use cloud-init and bash script
  # use https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config
  user_data = templatefile("${path.module}/agent.cloud-init.tpl", {
    ssh_key = base64encode(var.ssh_key),
    ssh_pub = base64encode(var.ssh_pub_key),
    vars    = [var.instana_agent_token, var.instana_agent_backend],
    }
  )
  tags = {
    Name = local.prefix
  }


}



output "agent_ec2_id" {
  value = aws_instance.instana.id
}


output "agent_ec2_ip" {
  value = aws_instance.instana.private_ip
}

output "agent_ec2_user_data" {
  description = "Instance user_data (aka init config)"
  value       = format("aws ec2 describe-instance-attribute --instance-id %s --attribute userData --output text --query \"UserData.Value\" | base64 --decode", aws_instance.instana.id)
}
