locals {
  operator_roles_properties = [
    {
      operator_name      = "installer-cloud-credentials"
      operator_namespace = "openshift-image-registry"
      role_name          = "openshift-image-registry-installer-cloud-credentials"
      policy_details     = "arn:aws:iam::aws:policy/service-role/ROSAImageRegistryOperatorPolicy"
      service_accounts   = ["system:serviceaccount:openshift-image-registry:cluster-image-registry-operator", "system:serviceaccount:openshift-image-registry:registry"]
    },
    {
      operator_name      = "cloud-credentials"
      operator_namespace = "openshift-ingress-operator"
      role_name          = "openshift-ingress-operator-cloud-credentials"
      policy_details     = "arn:aws:iam::aws:policy/service-role/ROSAIngressOperatorPolicy"
      service_accounts   = ["system:serviceaccount:openshift-ingress-operator:ingress-operator"]
    },
    {
      operator_name      = "ebs-cloud-credentials"
      operator_namespace = "openshift-cluster-csi-drivers"
      role_name          = "openshift-cluster-csi-drivers-ebs-cloud-credentials"
      policy_details     = "arn:aws:iam::aws:policy/service-role/ROSAAmazonEBSCSIDriverOperatorPolicy"
      service_accounts   = ["system:serviceaccount:openshift-cluster-csi-drivers:aws-ebs-csi-driver-operator", "system:serviceaccount:openshift-cluster-csi-drivers:aws-ebs-csi-driver-controller-sa"]
    },
    {
      operator_name      = "cloud-credentials"
      operator_namespace = "openshift-cloud-network-config-controller"
      role_name          = "openshift-cloud-network-config-controller-cloud-credentials"
      policy_details     = "arn:aws:iam::aws:policy/service-role/ROSACloudNetworkConfigOperatorPolicy"
      service_accounts   = ["system:serviceaccount:openshift-cloud-network-config-controller:cloud-network-config-controller"]
    },
    {
      operator_name      = "kube-controller-manager"
      operator_namespace = "kube-system"
      role_name          = "kube-system-kube-controller-manager"
      policy_details     = "arn:aws:iam::aws:policy/service-role/ROSAKubeControllerPolicy"
      service_accounts   = ["system:serviceaccount:kube-system:kube-controller-manager"]
    },
    {
      operator_name      = "capa-controller-manager"
      operator_namespace = "kube-system"
      role_name          = "kube-system-capa-controller-manager"
      policy_details     = "arn:aws:iam::aws:policy/service-role/ROSANodePoolManagementPolicy"
      service_accounts   = ["system:serviceaccount:kube-system:capa-controller-manager"]
    },
    {
      operator_name      = "control-plane-operator"
      operator_namespace = "kube-system"
      role_name          = "kube-system-control-plane-operator"
      policy_details     = "arn:aws:iam::aws:policy/service-role/ROSAControlPlaneOperatorPolicy"
      service_accounts   = ["system:serviceaccount:kube-system:control-plane-operator"]
    },
    {
      operator_name      = "kms-provider"
      operator_namespace = "kube-system"
      role_name          = "kube-system-kms-provider"
      policy_details     = "arn:aws:iam::aws:policy/service-role/ROSAKMSProviderPolicy"
      service_accounts   = ["system:serviceaccount:kube-system:kms-provider"]
    },
  ]
  operator_roles_count = length(local.operator_roles_properties)
  oidc_endpoint_url    = rhcs_rosa_oidc_config.oidc_config.oidc_endpoint_url
}

data "aws_iam_policy_document" "operator_custom_trust_policy" {
  count = local.operator_roles_count

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_endpoint_url}"]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_endpoint_url}:sub"
      values   = local.operator_roles_properties[count.index].service_accounts
    }
  }
}

resource "aws_iam_role" "operator_role" {
  count              = local.operator_roles_count
  name               = substr("${local.prefix}-${local.operator_roles_properties[count.index].operator_namespace}-${local.operator_roles_properties[count.index].operator_name}", 0, 64)
  assume_role_policy = data.aws_iam_policy_document.operator_custom_trust_policy[count.index].json

  # do not change these, w/o these tags OpenShift will not install...
  tags = merge(var.aws_tags, {
    rosa_managed_policies = true
    rosa_hcp_policies     = true
    red-hat-managed       = true
    operator_namespace    = local.operator_roles_properties[count.index].operator_namespace
    operator_name         = local.operator_roles_properties[count.index].operator_name
  })
}

resource "aws_iam_role_policy_attachment" "operator_role_policy_attachment" {
  count      = local.operator_roles_count
  role       = aws_iam_role.operator_role[count.index].name
  policy_arn = local.operator_roles_properties[count.index].policy_details
}
