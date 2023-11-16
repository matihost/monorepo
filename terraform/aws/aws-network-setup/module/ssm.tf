# Enabling AWS Systems Manager by default across all EC2 instances in an account/region
# by enabling Default Host Management Configuration (DHMC)
# TODO replace wwhen https://github.com/hashicorp/terraform-provider-aws/issues/30474 implemented
resource "aws_ssm_service_setting" "default_host_management" {
  setting_id    = "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:servicesetting/ssm/managed-instance/default-ec2-instance-management-role"
  setting_value = aws_iam_role.default_host_management.name
}


resource "aws_iam_role" "default_host_management" {
  name = "DefaultHostManagement"

  assume_role_policy = <<-EOF
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Principal": {
                  "Service": "ssm.amazonaws.com"
              },
              "Action": "sts:AssumeRole"
          }
      ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "default_host_management" {
  role       = aws_iam_role.default_host_management.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedEC2InstanceDefaultPolicy"
}


# To connect/ssh to EC2 via SSM
# ECM2 has to be either:
# public facing (be in public subnet)
# or
# it can be private only but it has to have assigned
# instance profile containing minimally AmazonSSMManagedInstanceCore policy
resource "aws_iam_role" "ssm-ec2" {
  name               = "SSM-EC2"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Principal": {"Service": "ec2.amazonaws.com"},
    "Action": "sts:AssumeRole"
  }
}
EOF
}

resource "aws_iam_instance_profile" "ssm-ec2" {
  name = "SSM-EC2"
  role = aws_iam_role.ssm-ec2.name
}



resource "aws_iam_role_policy_attachment" "ssm-ec2" {
  role       = aws_iam_role.ssm-ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_security_group" "ssm" {
  name        = "${var.env}-ssm"
  description = "Allow TLS inbound traffic for SSM/EC2 endpoints"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]

  }
  tags = {
    Name = "${var.env}-ssm"
  }
}


locals{
  subnet_ids =  [for subnet in aws_subnet.private: subnet.id]
}

# VPC endpoint for the Systems Manager service
# - https://aws.amazon.com/premiumsupport/knowledge-center/ec2-systems-manager-vpc-endpoints/
resource "aws_vpc_endpoint" "ssm_endpoint" {
  vpc_id              = data.aws_vpc.default.id
  service_name        = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = local.subnet_ids
  security_group_ids  = [aws_security_group.ssm.id]
  private_dns_enabled = true

  tags = {
    Name = "${try(data.aws_vpc.default.tags.Name, data.aws_vpc.default.id)}-ssm"
  }
}

# VPC endpoint for SSM Agent to make calls to the Systems Manager service
resource "aws_vpc_endpoint" "ec2_messages_endpoint" {
  vpc_id              = data.aws_vpc.default.id
  service_name        = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = local.subnet_ids
  security_group_ids  = [aws_security_group.ssm.id]
  private_dns_enabled = true

  tags = {
    Name = "${try(data.aws_vpc.default.tags.Name, data.aws_vpc.default.id)}-ec2messages"
  }
}

# VPC endpoint for connecting to EC2 instances through a secure data channel using Session Manager
resource "aws_vpc_endpoint" "ssm_messages_endpoint" {
  vpc_id              = data.aws_vpc.default.id
  service_name        = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = local.subnet_ids
  security_group_ids  = [aws_security_group.ssm.id]
  private_dns_enabled = true

  tags = {
    Name = "${try(data.aws_vpc.default.tags.Name, data.aws_vpc.default.id)}-ssmmessages"
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# Optional VPC endpoints for AWS Systems Manager
#
# References:
# - https://aws.amazon.com/premiumsupport/knowledge-center/ec2-systems-manager-vpc-endpoints/
# - https://docs.aws.amazon.com/systems-manager/latest/userguide/setup-create-vpc.html#sysman-setting-up-vpc-create
# ---------------------------------------------------------------------------------------------------------------------

# VPC endpoint for Systems Manager to create VSS-enabled snapshots
resource "aws_vpc_endpoint" "ec2_endpoint" {
  vpc_id              = data.aws_vpc.default.id
  service_name        = "com.amazonaws.${var.region}.ec2"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = local.subnet_ids
  security_group_ids  = [aws_security_group.ssm.id]
  private_dns_enabled = true

  tags = {
    Name = "${try(data.aws_vpc.default.tags.Name, data.aws_vpc.default.id)}-ec2"
  }
}

# VPC endpoint for AWS Key Management Service (AWS KMS) encryption for Session Manager or Parameter Store parameters
resource "aws_vpc_endpoint" "kms_endpoint" {
  vpc_id              = data.aws_vpc.default.id
  service_name        = "com.amazonaws.${var.region}.kms"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = local.subnet_ids
  security_group_ids  = [aws_security_group.ssm.id]
  private_dns_enabled = true

  tags = {
    Name = "${try(data.aws_vpc.default.tags.Name, data.aws_vpc.default.id)}-kms"
  }
}

# VPC endpoint for Amazon CloudWatch Logs (CloudWatch Logs) for Session Manager, Run Command, or SSM Agent logs
resource "aws_vpc_endpoint" "logs_endpoint" {
  vpc_id              = data.aws_vpc.default.id
  service_name        = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = local.subnet_ids
  security_group_ids  = [aws_security_group.ssm.id]
  private_dns_enabled = true

  tags = {
    Name = "${try(data.aws_vpc.default.tags.Name, data.aws_vpc.default.id)}-logs"
  }
}
