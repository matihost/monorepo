# Required to be able to set instance_profile on EC2 instance
resource "aws_iam_policy" "passInstanceProfile" {
  name        = "AllowPassingInstanceProfileToEC2"
  path        = "/"
  description = "Allow to assing EC2 to InstanceProfile"

  policy = <<-EOF
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Action": [
                  "iam:PassRole",
                  "iam:ListInstanceProfiles"
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
  name        = "AllowDecodeAuthorizationMessages"
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
  name        = "AllowCreateAutoScalingGroupAndApplicationLoadBalancer"
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
