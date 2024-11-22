locals {
  account_roles_properties = [
    {
      role_name            = "HCP-ROSA-Installer"
      role_type            = "installer"
      policy_details       = data.rhcs_hcp_policies.all_policies.account_role_policies["sts_hcp_installer_permission_policy"]
      principal_type       = "AWS"
      principal_identifier = "arn:${data.aws_partition.current.partition}:iam::${data.rhcs_info.current.ocm_aws_account_id}:role/RH-Managed-OpenShift-Installer"
    },
    {
      role_name      = "HCP-ROSA-Support"
      role_type      = "support"
      policy_details = data.rhcs_hcp_policies.all_policies.account_role_policies["sts_hcp_support_permission_policy"]
      principal_type = "AWS"
      // This is a SRE RH Support role which is used to assume this support role
      principal_identifier = data.rhcs_hcp_policies.all_policies.account_role_policies["sts_support_rh_sre_role"]
    },
    {
      role_name            = "HCP-ROSA-Worker"
      role_type            = "instance_worker"
      policy_details       = data.rhcs_hcp_policies.all_policies.account_role_policies["sts_hcp_instance_worker_permission_policy"]
      principal_type       = "Service"
      principal_identifier = "ec2.amazonaws.com"
    },
  ]
  account_roles_count = length(local.account_roles_properties)
}

data "aws_iam_policy_document" "account_custom_trust_policy" {
  count = local.account_roles_count

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = local.account_roles_properties[count.index].principal_type
      identifiers = [local.account_roles_properties[count.index].principal_identifier]
    }
  }
}

resource "aws_iam_role" "account_role" {
  count              = local.account_roles_count
  name               = substr("${local.prefix}-${local.account_roles_properties[count.index].role_name}-Role", 0, 64)
  assume_role_policy = data.aws_iam_policy_document.account_custom_trust_policy[count.index].json


  # do not change these, w/o these tags OpenShift will not install...
  tags = merge(var.aws_tags, {
    red-hat-managed       = true
    rosa_hcp_policies     = true
    rosa_managed_policies = true
    rosa_role_prefix      = local.prefix
    rosa_role_type        = local.account_roles_properties[count.index].role_type
  })
}

resource "aws_iam_role_policy_attachment" "account_role_policy_attachment" {
  count      = local.account_roles_count
  role       = aws_iam_role.account_role[count.index].name
  policy_arn = local.account_roles_properties[count.index].policy_details
}


data "rhcs_hcp_policies" "all_policies" {}

data "aws_partition" "current" {}

data "rhcs_info" "current" {}
