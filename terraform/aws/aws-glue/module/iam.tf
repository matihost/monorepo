# Role to interact with AWS GUI Console and AWS GUI for Glue service

resource "aws_iam_policy" "glue-data-s3-policy" {
  description = "Access to S3 used by Glue Execution and Console"
  name        = "GlueData-S3Policy"

  policy = <<EOF
{
  "Statement": [
    {
      "Action": [
        "s3:Get*",
        "s3:List*",
        "s3:*Object*"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::dev-glue-data-${local.account_id}",
        "arn:aws:s3:::dev-glue-data-${local.account_id}/*"
      ]
    }
  ],
  "Version": "2012-10-17"
}
EOF
}

resource "aws_iam_policy" "glue-pass-to-exec-role-policy" {
  description = "Allow to switch to Glue exec role"
  name        = "AWSGlue-PassToExecRole-dev-glue-exec-role"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "arn:aws:iam::${local.account_id}:role/dev-glue-exec-role"
        }
    ]
}
EOF
}


resource "aws_iam_role" "glue-user-role" {
  name = "${var.env}-glue-console-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${local.account_id}:root"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "glue-user-role-s3-access" {
  role       = aws_iam_role.glue-user-role.name
  policy_arn = aws_iam_policy.glue-data-s3-policy.arn
}


resource "aws_iam_role_policy_attachment" "glue-user-pass-to-exec-role" {
  role       = aws_iam_role.glue-user-role.name
  policy_arn = aws_iam_policy.glue-pass-to-exec-role-policy.arn
}

resource "aws_iam_role_policy_attachment" "glue-user-role-console-access" {
  role       = aws_iam_role.glue-user-role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess"
}



# AWS Role used to run Job (part of Glue Job definition)
resource "aws_iam_role" "glue-exec-role" {
  name = "${var.env}-glue-exec-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "glue.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}


resource "aws_iam_role_policy_attachment" "glue-exec-role-s3-access" {
  role       = aws_iam_role.glue-exec-role.name
  policy_arn = aws_iam_policy.glue-data-s3-policy.arn
}

resource "aws_iam_role_policy_attachment" "glue-exec-role-console-access" {
  role       = aws_iam_role.glue-exec-role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess"
}


# Glue Service Role
resource "aws_iam_role" "aws-glue-service-role" {
  assume_role_policy = <<POLICY
{
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "glue.amazonaws.com"
      }
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  managed_policy_arns = [aws_iam_policy.glue-s3-service-policy.arn,
    "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
  ]
  name = "AWSGlueServiceRole"
  path = "/service-role/"
}

resource "aws_iam_policy" "glue-s3-service-policy" {
  description = "This policy will be used for Glue Crawler and Job execution. Please do NOT delete!"
  name        = "AWSGlueServiceRole-s3Policy"
  path        = "/service-role/"

  policy = <<POLICY
{
  "Statement": [
    {
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::aws-glue-assets-${local.account_id}-us-east-1/*"
      ]
    }
  ],
  "Version": "2012-10-17"
}
POLICY
}
