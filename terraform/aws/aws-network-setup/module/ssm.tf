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
