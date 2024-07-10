resource "aws_iam_role" "jenkins-master" {
  name               = "${local.prefix}-master"
  description        = "Should be applied to EC2 with Jenkins Master - so that Jenkins can spawn Jenkins Agent being EC2s"
  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
}

# Only roles exposed as instance_profile can be assigned to EC2
# EC2 instance can obtain the credentials via:
# curl http://169.254.169.254/latest/meta-data/iam/security-credentials/s3all
# AWS CLI inherits them automatically
resource "aws_iam_instance_profile" "jenkins-master" {
  name = "${local.prefix}-master"
  role = aws_iam_role.jenkins-master.name
}

resource "aws_iam_role_policy_attachment" "jenkins-master-s3-attach" {
  role       = aws_iam_role.jenkins-master.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "jenkins-master-ec2-attach" {
  role       = aws_iam_role.jenkins-master.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "jenkins-master-ssm" {
  role       = aws_iam_role.jenkins-master.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "jenkins-master-cloudwatch" {
  role       = aws_iam_role.jenkins-master.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}


# TODO apply instance profile on Jenkins Agents
# https://plugins.jenkins.io/ec2/#plugin-content-iam-setup
resource "aws_iam_role" "jenkins-agent" {
  name               = "${local.prefix}-agent"
  description        = "Should be applied to EC2 with Jenkins Agent"
  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
}

resource "aws_iam_instance_profile" "jenkins-agent" {
  name = "${local.prefix}-agent"
  role = aws_iam_role.jenkins-agent.name
}

resource "aws_iam_role_policy_attachment" "jenkins-agent-ssm" {
  role       = aws_iam_role.jenkins-agent.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "jenkins-agent-cloudwatch" {
  role       = aws_iam_role.jenkins-agent.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
