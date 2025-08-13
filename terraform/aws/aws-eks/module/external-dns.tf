# ExternalDNS
# https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws.md
resource "aws_iam_policy" "externaldns" {
  description = "Allows ExternalDNS pods update DNS resources"
  name        = "${local.prefix}-AllowExternalDNSUpdates"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets",
        "route53:ListTagsForResources"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}



resource "aws_iam_role" "externaldns" {
  name        = "${local.prefix}-AllowExternalDNSUpdates"
  description = "Allows ExternalDNS pods update DNS resources"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole", "sts:TagSession"]
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "externaldns" {
  policy_arn = aws_iam_policy.externaldns.arn
  role       = aws_iam_role.externaldns.name
}


resource "aws_eks_pod_identity_association" "externaldns" {
  cluster_name    = aws_eks_cluster.cluster.name
  namespace       = "kube-system"
  service_account = "external-dns"
  role_arn        = aws_iam_role.externaldns.arn
}
