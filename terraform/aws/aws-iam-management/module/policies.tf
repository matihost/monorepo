resource "aws_iam_policy" "selfmanagement" {
  name        = "SelfManagement"
  path        = "/"
  description = "Allow to user for self management"

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
          "Sid": "AllowOwnUserManagement",
          "Effect": "Allow",
          "Action": [
              "iam:GetLoginProfile",
              "iam:*AccessKey*",
              "iam:UpdateLoginProfile"
          ],
          "Resource": "arn:aws:iam::${local.account_id}:user/$${aws:username}"
        },
        {
          "Effect": "Allow",
          "Action": [
              "iam:List*",
              "iam:Get*"
          ],
          "Resource": "*"
        },
        {
          "Sid": "AllowUserToCRUDTheirMFA",
          "Effect": "Allow",
          "Action": [
              "iam:ListVirtualMFADevices",
              "iam:ListMFADevices",
              "iam:CreateVirtualMFADevice",
              "iam:DeactivateMFADevice",
              "iam:DeleteVirtualMFADevice",
              "iam:EnableMFADevice",
              "iam:ResyncMFADevice"
          ],
          "Resource": [
              "arn:aws:iam::${local.account_id}:mfa/*",
              "arn:aws:iam::${local.account_id}:user/$${aws:username}"
          ]
        }
    ]
  }
  EOF
}


# Required to be able to set instance_profile on EC2 instance
resource "aws_iam_policy" "passInstanceProfile" {
  name        = "PassInstanceProfileToEC2"
  path        = "/"
  description = "Allow to assign EC2 to InstanceProfile"

  policy = <<-EOF
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Action": [
                  "iam:PassRole",
                  "iam:GetInstanceProfile",
                  "iam:ListInstanceProfiles"
              ],
              "Resource": "*"
          }
      ]
  }
  EOF
}


resource "aws_iam_policy" "assumeRole" {
  name        = "AssumeRole_All"
  path        = "/"
  description = "Allow assuming role (act as a role)"

  policy = <<-EOF
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Action": [
                  "iam:ListRoles",
                  "sts:AssumeRole"
              ],
              "Resource": "*"
          }
      ]
  }
  EOF
}


resource "aws_iam_policy" "assume-read-only" {
  name        = "AssumeRole_ReadOnlyAccess"
  path        = "/"
  description = "Allow assuming role (act as a role)"

  policy = <<-EOF
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Action": [
                  "sts:AssumeRole"
              ],
              "Resource": "arn:aws:iam:::role/ReadOnlyAccess"
          }
      ]
  }
  EOF
}

resource "aws_iam_policy" "assume-admin" {
  name        = "AssumeRole_FullAdminAccess"
  path        = "/"
  description = "Allow assuming role (act as a role)"

  policy = <<-EOF
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Action": [
                  "sts:AssumeRole"
              ],
              "Resource": "arn:aws:iam:::role/FullAdminAccess"
          }
      ]
  }
  EOF
}

resource "aws_iam_policy" "billingViewAccess" {
  name        = "BillingViewAccess"
  path        = "/"
  description = "Allows users to access and view content on the Billing Console."

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "aws-portal:ViewPaymentMethods",
                "aws-portal:ViewAccount",
                "aws-portal:ViewBilling",
                "aws-portal:ViewUsage"
            ],
            "Resource": "*"
        }
    ]
  }
  EOF
}

# Required to run
# aws sts decode-authorization-message --encoded-message (encoded error message) --query DecodedMessage --output text | jq '.'
# to decode encoded authorization error messages
resource "aws_iam_policy" "decodeAuthorizedMessages" {
  name        = "DecodeAuthorizationMessages"
  path        = "/"
  description = "Allow to execute aws sts decode-authorization-message "

  policy = <<-EOF
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Action": "sts:DecodeAuthorizationMessage",
              "Resource": "*"
          }
      ]
  }
  EOF
}

# Required to create AutoScalingGroup and ALB
resource "aws_iam_policy" "createASGAndALB" {
  name        = "CreateAutoScalingGroupAndApplicationLoadBalancer"
  path        = "/"
  description = "Allow to create linked role for ASG and ALB"

  policy = <<-EOF
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Action": "iam:CreateServiceLinkedRole",
              "Resource": "arn:aws:iam::*:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling*",
              "Condition": {"StringLike": {"iam:AWSServiceName": "autoscaling.amazonaws.com"}}
          },
          {
              "Effect": "Allow",
              "Action": "iam:CreateServiceLinkedRole",
              "Resource": "arn:aws:iam::*:role/aws-service-role/elasticloadbalancing.amazonaws.com/AWSServiceRoleForElasticLoadBalancing*",
              "Condition": {"StringLike": {"iam:AWSServiceName": "elasticloadbalancing.amazonaws.com"}}
          },
          {
              "Effect": "Allow",
              "Action": [
                  "iam:AttachRolePolicy",
                  "iam:PutRolePolicy"
              ],
              "Resource": "arn:aws:iam::*:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling*"
          },
          {
              "Effect": "Allow",
              "Action": [
                  "iam:AttachRolePolicy",
                  "iam:PutRolePolicy"
              ],
              "Resource": "arn:aws:iam::*:role/aws-service-role/elasticloadbalancing.amazonaws.com/AWSServiceRoleForElasticLoadBalancing*"
          }
      ]
  }
  EOF
}
