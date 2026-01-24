locals {
  private_subnet_ids = [for subnet in data.aws_subnet.private : subnet.id]
}


data "aws_vpc" "vpc" {
  default = var.vpc_name == "default" ? true : null

  tags = var.vpc_name == "default" ? null : {
    Name = var.vpc_name
  }
}

data "aws_subnet" "private" {
  for_each          = var.zones
  vpc_id            = data.aws_vpc.vpc.id
  availability_zone = each.key
  tags = {
    Tier = "private"
  }
}

resource "aws_cloudwatch_log_group" "cluster" {
  name              = "/aws/eks/${local.prefix}/cluster"
  retention_in_days = 7
  # kms_key_id        = "..."

  tags = merge(
    var.aws_tags,
    { Name = "/aws/eks/${local.prefix}/cluster" }
  )
}

resource "aws_eks_cluster" "cluster" {
  name = local.prefix

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
    # realized via access entry instead
    bootstrap_cluster_creator_admin_permissions = false
  }

  role_arn = aws_iam_role.cluster.arn
  version  = var.cluster_version

  # "A list of the desired control plane logs to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)
  enabled_cluster_log_types = ["audit", "api", "authenticator"]

  # When EKS Auto Mode is enabled, bootstrapSelfManagedAddons must be set to false
  bootstrap_self_managed_addons = false

  compute_config {
    enabled = true
    # possible values "system", "general-purpose"
    # nodepool are created via Helm module/cluster-config-chart
    # default allows arm64 deployment while some EKS addons (like EFS) attempy to install amd64 images resulting
    # in: 'exec format error' error
    # system also allows arm64, but it has to be specified otherwise:  When Compute Config nodeRoleArn is not null or empty, nodePool value(s) must be provided
    node_pools    = ["system"]
    node_role_arn = aws_iam_role.node.arn
  }

  kubernetes_network_config {
    elastic_load_balancing {
      enabled = true
    }
    service_ipv4_cidr = var.service_cidr
  }

  storage_config {
    block_storage {
      enabled = true
    }
  }

  vpc_config {
    # TODO make own instead,
    # By default EKS Auto creates SecurityGroup allow access only from same SG and allowing all outbound
    # security_group_ids = ...
    endpoint_private_access = true
    endpoint_public_access  = true

    subnet_ids = local.private_subnet_ids
  }

  # TODO add encryption for Secrets
  #
  # encryption_config {
  #   provider {
  #     key_arn = "..."
  #   }
  #   resources = [ "secrets" ]
  # }

  upgrade_policy {
    support_type = "STANDARD"
  }

  zonal_shift_config {
    enabled = true
  }

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_cloudwatch_log_group.cluster,
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSComputePolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSBlockStoragePolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSLoadBalancingPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSNetworkingPolicy,
  ]

  lifecycle {
    ignore_changes = [
      access_config[0].bootstrap_cluster_creator_admin_permissions
    ]
  }
}

resource "aws_iam_role" "node" {
  name = "${local.prefix}-eks-auto-node"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}


# To collect AmazonEBS Volume IDs in Logs via EKS CloudWatch Addon
# https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/install-CloudWatch-Observability-EKS-addon.html
resource "aws_iam_role_policy" "node_ReadEBSVolumeIDs" {
  name = "CollectEBSvolumeIDs"
  role = aws_iam_role.node.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ec2:DescribeVolumes"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodeMinimalPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodeMinimalPolicy"
  role       = aws_iam_role.node.name
}

# to download images from this account ECR
resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryPullOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  role       = aws_iam_role.node.name
}

# To be able to install Cloud Watch EKS Addons with access to all metrics
resource "aws_iam_role_policy_attachment" "node_CloudWatchAgentServerPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.node.name
}


resource "aws_iam_role" "cluster" {
  name = "${local.prefix}-eks-cluster"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSComputePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSComputePolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSBlockStoragePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSLoadBalancingPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSNetworkingPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy"
  role       = aws_iam_role.cluster.name
}


resource "null_resource" "cluster-config" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "${path.module}/configure-cluster.sh '${local.account_id}' '${aws_eks_cluster.cluster.name}' '${var.region}' '${jsonencode(var.namespaces)}' '${var.install_nginx}' '${nonsensitive(var.dd_api_key)}' '${nonsensitive(var.dd_app_key)}'"
  }

  depends_on = [
    aws_iam_role.cluster,
    aws_eks_access_entry.admin,
    aws_eks_access_policy_association.admin,
    aws_eks_pod_identity_association.externaldns,
    aws_iam_role_policy_attachment.backup_irsa,
  ]
}
