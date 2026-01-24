resource "aws_s3_bucket" "backup" {
  bucket              = "${local.account_id}-${local.prefix}-velero-backups"
  force_destroy       = "true"
  object_lock_enabled = "false"
}


resource "aws_s3_bucket_server_side_encryption_configuration" "backup_enc" {
  bucket = aws_s3_bucket.backup.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }

    bucket_key_enabled = "true"
  }
}


resource "aws_s3_bucket_versioning" "backup_versioning" {
  bucket = aws_s3_bucket.backup.id
  versioning_configuration {
    status = "Disabled"
  }
}


data "aws_iam_policy_document" "backup_irsa_trust_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.oidc_provider.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${aws_iam_openid_connect_provider.oidc_provider.url}:sub"
      values   = ["system:serviceaccount:velero:velero-server"]
    }
  }
}


resource "aws_iam_role" "backup_irsa" {
  name               = "${local.prefix}-velero-irsa"
  assume_role_policy = data.aws_iam_policy_document.backup_irsa_trust_policy.json
}

resource "aws_iam_role_policy_attachment" "backup_irsa" {
  policy_arn = aws_iam_policy.velero-policy.arn
  role       = aws_iam_role.backup_irsa.name
}


resource "aws_iam_policy" "velero-policy" {
  description = "Allow pass ReadOnlyAccess role to Tools"
  name        = "${local.prefix}-velero-irsa"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeVolumes",
                "ec2:DescribeSnapshots",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:CreateSnapshot",
                "ec2:DeleteSnapshot"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:PutObject",
                "s3:AbortMultipartUpload",
                "s3:ListMultipartUploadParts"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.backup.bucket}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.backup.bucket}"
            ]
        }
    ]
}
EOF
}
