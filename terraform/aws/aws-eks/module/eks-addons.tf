# The following addons are preinstalled and managed by EKS Auto Mode automatically:
# https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html#addon-consider-auto
# CoreDNS
# KubeProxy
# AWS Load Balancer Controller
# Karpenter
# AWS EBS CSI Driver
# EKS Pod Identity Agent https://docs.aws.amazon.com/eks/latest/userguide/pod-id-association.html
#
# Since addons are added automatically - there is different way to configure them:
# https://docs.aws.amazon.com/eks/latest/userguide/settings-auto.html
# for example to define tags for LoadBalancers.

resource "aws_eks_addon" "snapshot-controller" {
  cluster_name = aws_eks_cluster.cluster.name
  addon_name   = "snapshot-controller"
  # addon_version               = "v8.2.0-eksbuild.2"
  resolve_conflicts_on_create = "OVERWRITE"

  configuration_values = jsonencode(
    {
      "nodeSelector" : {
        "karpenter.sh/nodepool" : "system"
      }
    }
  )
}

# https://docs.aws.amazon.com/eks/latest/userguide/workloads-add-ons-available-eks.html#add-ons-aws-efs-csi-driver
resource "aws_eks_addon" "efs" {
  cluster_name = aws_eks_cluster.cluster.name
  addon_name   = "aws-efs-csi-driver"
  # addon_version               = "v2.1.9-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"

  pod_identity_association {
    role_arn        = aws_iam_role.efs-addon.arn
    service_account = "efs-csi-controller-sa"
  }

  # efs-csi is only amd64, arm64 is not supported
  configuration_values = jsonencode(
    {
      "controller" : {
        "nodeSelector" : {
          "karpenter.sh/nodepool" : "system",
          "kubernetes.io/arch" : "amd64"
        },
        "tolerations" : [
          {
            "key" : "CriticalAddonsOnly",
            "operator" : "Exists"
          },
          {
            "effect" : "NoExecute",
            "operator" : "Exists",
            "tolerationSeconds" : 300
          }
        ]
      }
    }
  )
}


resource "aws_iam_role" "efs-addon" {
  name        = "${local.prefix}-AmazonEKSPodIdentityAmazonEFSCSIDriverRole"
  description = "Allows pods running in Amazon EKS cluster to access AWS resources."
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



resource "aws_iam_role_policy_attachment" "efs-addon_AmazonEFSCSIDriverPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
  role       = aws_iam_role.efs-addon.name
}

# CloudWatch addons does not support Pod Identifies yet, only IRSA or node level role
# TODO evaluate more configuration options
# https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/install-CloudWatch-Observability-EKS-addon.html
# https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/metrics-collected-by-CloudWatch-agent.html
resource "aws_eks_addon" "cloudwatch" {
  cluster_name = aws_eks_cluster.cluster.name
  addon_name   = "amazon-cloudwatch-observability"
  # addon_version               = "v4.3.0-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"


  configuration_values = jsonencode(
    { "containerLogs" : { "enabled" : true },
      "tolerations" : [
        {
          "key" : "CriticalAddonsOnly",
          "operator" : "Exists"
        },
        {
          "effect" : "NoExecute",
          "operator" : "Exists",
          "tolerationSeconds" : 300
        }
      ]
    }
  )
}
