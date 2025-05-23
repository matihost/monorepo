# Enabling AWS Systems Manager by default across all EC2 instances in an account/region
# by enabling Default Host Management Configuration (DHMC)
#
# To connect/ssh to EC2 via SSM
# EC2 has to be either:
# public facing (be in public subnet)
# or
# it can be private only but
# DefaultHostManagement is configured in the region (defined in aws-network-setup module)
# (so that instance profile attached to EC2 instance automatically has necessary permission to use SSM
# or explicitely add instance profile to EC2 containing minimally AmazonSSMManagedInstanceCore policy (like tihs SSM-EC2 role)
#
# WARNING:
# Depending on SSM settings:
# https://us-east-1.console.aws.amazon.com/systems-manager/session-manager/preferences?region=us-east-1#
# whether SSM populates logs to CloudWatch or encrypted S3
# then more IAM privileges needed to be applied on either DefaultHostManagement role or instance profile attached to EC2:
# https://repost.aws/knowledge-center/ssm-session-manager-failures

# TODO replace when https://github.com/hashicorp/terraform-provider-aws/issues/30474 implemented
resource "aws_ssm_service_setting" "default_host_management" {
  setting_id    = "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:servicesetting/ssm/managed-instance/default-ec2-instance-management-role"
  setting_value = data.aws_iam_role.default_host_management.name
}

# Role is created in aws-iam-linked module
data "aws_iam_role" "default_host_management" {
  name = "DefaultHostManagement"

}


resource "aws_security_group" "ssm" {
  name        = "${local.prefix}-ssm"
  description = "Allow TLS inbound traffic for SSM/EC2 endpoints"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]

  }
  tags = {
    Name = "${var.env}-ssm"
  }
}


locals {
  subnet_ids = [for subnet in aws_subnet.private : subnet.id]
}

# VPC endpoint for the Systems Manager service
# - https://aws.amazon.com/premiumsupport/knowledge-center/ec2-systems-manager-vpc-endpoints/
resource "aws_vpc_endpoint" "ssm_endpoint" {
  count = var.create_ssm_private_access_vpc_endpoints ? 1 : 0

  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = local.subnet_ids
  security_group_ids  = [aws_security_group.ssm.id]
  private_dns_enabled = true

  tags = {
    Name = "${try(aws_vpc.main.tags.Name, aws_vpc.main.id)}-ssm"
  }
}

# VPC endpoint for SSM Agent to make calls to the Systems Manager service
resource "aws_vpc_endpoint" "ec2_messages_endpoint" {
  count = var.create_ssm_private_access_vpc_endpoints ? 1 : 0

  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = local.subnet_ids
  security_group_ids  = [aws_security_group.ssm.id]
  private_dns_enabled = true

  tags = {
    Name = "${try(aws_vpc.main.tags.Name, aws_vpc.main.id)}-ec2messages"
  }
}

# VPC endpoint for connecting to EC2 instances through a secure data channel using Session Manager
resource "aws_vpc_endpoint" "ssm_messages_endpoint" {
  count = var.create_ssm_private_access_vpc_endpoints ? 1 : 0

  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = local.subnet_ids
  security_group_ids  = [aws_security_group.ssm.id]
  private_dns_enabled = true

  tags = {
    Name = "${try(aws_vpc.main.tags.Name, aws_vpc.main.id)}-ssmmessages"
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
  count = var.create_ssm_private_access_vpc_endpoints ? 1 : 0

  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ec2"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = local.subnet_ids
  security_group_ids  = [aws_security_group.ssm.id]
  private_dns_enabled = true

  tags = {
    Name = "${try(aws_vpc.main.tags.Name, aws_vpc.main.id)}-ec2"
  }
}

# VPC endpoint for AWS Key Management Service (AWS KMS) encryption for Session Manager or Parameter Store parameters
resource "aws_vpc_endpoint" "kms_endpoint" {
  count = var.create_ssm_private_access_vpc_endpoints ? 1 : 0

  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.kms"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = local.subnet_ids
  security_group_ids  = [aws_security_group.ssm.id]
  private_dns_enabled = true

  tags = {
    Name = "${try(aws_vpc.main.tags.Name, aws_vpc.main.id)}-kms"
  }
}

# VPC endpoint for Amazon CloudWatch Logs (CloudWatch Logs) for Session Manager, Run Command, or SSM Agent logs
resource "aws_vpc_endpoint" "logs_endpoint" {
  count = var.create_ssm_private_access_vpc_endpoints ? 1 : 0

  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = local.subnet_ids
  security_group_ids  = [aws_security_group.ssm.id]
  private_dns_enabled = true

  tags = {
    Name = "${try(aws_vpc.main.tags.Name, aws_vpc.main.id)}-logs"
  }
}
