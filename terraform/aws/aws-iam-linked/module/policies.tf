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



resource "aws_iam_policy" "amiBuilder" {
  name        = "AMIBuilder"
  path        = "/"
  description = "Allow to create AMI (Minimal Packer requirements)"

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ec2:AttachVolume",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:CopyImage",
          "ec2:CreateImage",
          "ec2:CreateKeypair",
          "ec2:CreateSecurityGroup",
          "ec2:CreateSnapshot",
          "ec2:CreateTags",
          "ec2:CreateVolume",
          "ec2:DeleteKeyPair",
          "ec2:DeleteSecurityGroup",
          "ec2:DeleteSnapshot",
          "ec2:DeleteVolume",
          "ec2:DeregisterImage",
          "ec2:DescribeImageAttribute",
          "ec2:DescribeImages",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeRegions",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSnapshots",
          "ec2:DescribeSubnets",
          "ec2:DescribeTags",
          "ec2:DescribeVolumes",
          "ec2:DetachVolume",
          "ec2:GetPasswordData",
          "ec2:ModifyImageAttribute",
          "ec2:ModifyInstanceAttribute",
          "ec2:ModifySnapshotAttribute",
          "ec2:RegisterImage",
          "ec2:RunInstances",
          "ec2:StopInstances",
          "ec2:TerminateInstances",
          "ec2:CreateLaunchTemplate",
          "ec2:DeleteLaunchTemplate",
          "ec2:CreateFleet",
          "ec2:DescribeSpotPriceHistory",
          "ec2:DescribeVpcs",
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


resource "aws_iam_policy" "tools-access" {
  description = "Allow pass ReadOnlyAccess role to Tools"
  name        = "AllowPassReadOnlyAccessRoleToTools"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "ts:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [ "iam:PassRole", "iam:GetRole" ],
            "Resource": "arn:aws:iam::${local.account_id}:role/ReadOnlyAccess",
            "Condition": {"StringEquals": {"iam:PassedToService": "ts.amazonaws.com"}}
        }
    ]
}
EOF
}
