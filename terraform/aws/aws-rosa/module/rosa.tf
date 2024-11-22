locals {
  private_subnet_ids = [for subnet in data.aws_subnet.private : subnet.id]
  installer_role_arn = aws_iam_role.account_role[0].arn

  cluster_admin_credentials = var.cluster_admin_password == "" ? null : { username = "cluster-admin", password = var.cluster_admin_password }
}

# TODO retrieve latest version and use optionally as version of the cluster
# tflint-ignore: terraform_unused_declarations
data "rhcs_versions" "all" {
  order = "id desc"
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

# Warning:
# ROSA does not support removal via Terraform
# Attempt to remove cluster via terraform ignores depends_on and it deletes account_roles first
# causing that cluster deletion handgs forever...
# Also attempt to delete the cluster by deleting cluster nad machine objects leads to error - that it is not possible
# to delete all machine pools (there must be 2 replicas all the time)
# The only way to delete cluster and all resources is to remove it via rosa cli and then continue via tf destroy.
resource "rhcs_cluster_rosa_hcp" "rosa_hcp_cluster" {
  name                         = local.prefix
  domain_prefix                = local.prefix
  version                      = var.openshift_version
  upgrade_acknowledgements_for = var.max_upgrade_version
  private                      = true
  properties = merge(
    {
      rosa_creator_arn = data.aws_caller_identity.current.arn
    },
    var.aws_tags
  )
  cloud_region           = var.region
  aws_account_id         = local.account_id
  aws_billing_account_id = var.billing_account_id == "" ? local.account_id : var.billing_account_id
  sts = {
    role_arn         = local.installer_role_arn,
    support_role_arn = aws_iam_role.account_role[1].arn
    instance_iam_roles = {
      worker_role_arn = aws_iam_role.account_role[2].arn
    },
    operator_role_prefix = local.prefix,
    oidc_config_id       = rhcs_rosa_oidc_config.oidc_config.id
  }

  availability_zones       = var.zones
  replicas                 = length(var.zones)
  aws_subnet_ids           = local.private_subnet_ids
  compute_machine_type     = var.machine_instance_type
  create_admin_user        = var.cluster_admin_password != ""
  admin_credentials        = local.cluster_admin_credentials
  ec2_metadata_http_tokens = "required"

  # https://docs.openshift.com/rosa/networking/cidr-range-definitions.html#machine-cidr-description
  machine_cidr = data.aws_vpc.vpc.cidr_block
  service_cidr = var.service_cidr
  pod_cidr     = var.pod_cidr
  host_prefix  = var.host_prefix

  # TODO add encryption on top of storage encryption
  etcd_encryption = false
  # etcd_kms_key_arn = var.etcd_kms_key_arn
  # kms_key_arn      = var.kms_key_arn

  wait_for_create_complete            = true
  wait_for_std_compute_nodes_complete = true
  disable_waiting_in_destroy          = false
  destroy_timeout                     = 60 # minutes


  depends_on = [
    aws_iam_role.account_role,
    aws_iam_role.operator_role
  ]

  lifecycle {
    ignore_changes = [create_admin_user, admin_credentials, replicas, compute_machine_type]
  }
}


# TODO add autoscaller
# As of terraform-redhat/rhcs v1.6.6
# currently the object is not implemented, enabling it ends with error
# resource "rhcs_hcp_cluster_autoscaler" "cluster_autoscaler" {
#   count = var.enable_cluster_autoscaler ? 1 : 0

#   cluster                 = rhcs_cluster_rosa_hcp.rosa_hcp_cluster.id
#   max_pod_grace_period    = var.autoscaler_max_pod_grace_period
#   pod_priority_threshold  = var.autoscaler_pod_priority_threshold
#   max_node_provision_time = var.autoscaler_max_node_provision_time

#   resource_limits = {
#     max_nodes_total = var.autoscaler_max_nodes_total
#   }
# }

resource "rhcs_hcp_default_ingress" "default_ingress" {
  cluster          = rhcs_cluster_rosa_hcp.rosa_hcp_cluster.id
  listening_method = "internal"
}


resource "rhcs_kubeletconfig" "kubeletconfig" {
  cluster        = rhcs_cluster_rosa_hcp.rosa_hcp_cluster.id
  pod_pids_limit = var.pod_limit
}

# Default machine poools (aka workers-0, workers-1,...) are not editable after initial cluster creation
# The solution is to add additional machine pools and remove default ones
resource "rhcs_hcp_machine_pool" "machine_pool" {
  for_each = var.zones

  cluster = rhcs_cluster_rosa_hcp.rosa_hcp_cluster.id
  # name is max 15 characters
  name = "compute-${trimprefix(each.key, var.region)}"

  # it is valid to have replica with 0 nodes, as soon as there are at least 2 replicas in total in the cluster left
  replicas = var.enable_cluster_autoscaler ? null : var.replicas_per_zone
  autoscaling = {
    enabled = var.enable_cluster_autoscaler
    # must be greater than zero.
    min_replicas = var.enable_cluster_autoscaler ? 1 : null
    max_replicas = var.enable_cluster_autoscaler ? var.autoscaler_max_nodes_per_zone : null

  }
  labels    = var.labels
  taints    = var.taints
  subnet_id = data.aws_subnet.private[each.key].id
  aws_node_pool = {
    instance_type = var.machine_instance_type
    tags          = var.aws_tags
  }
  auto_repair                  = true
  version                      = var.openshift_version
  upgrade_acknowledgements_for = var.max_upgrade_version
  # tuning_configs               = ...
  # kubelet_configs              = ...
  ignore_deletion_error = false

  lifecycle {
    ignore_changes = [
      cluster,
      name,
    ]
  }
}


resource "null_resource" "clean_default_machines" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "${path.module}/delete-machine-pools.sh '${rhcs_cluster_rosa_hcp.rosa_hcp_cluster.id}' 'workers-'"
  }

  depends_on = [
    rhcs_cluster_rosa_hcp.rosa_hcp_cluster,
    rhcs_hcp_machine_pool.machine_pool
  ]
}


# TODO add own IDP based on Keycloak
# example with ENtraID: https://docs.redhat.com/en/documentation/red_hat_openshift_service_on_aws/4/html-single/tutorials/index#cloud-experts-entra-id-idp-register-application
# https://registry.terraform.io/providers/terraform-redhat/rhcs/latest/docs/resources/identity_provider#nested-schema-for-openid
# https://github.com/terraform-redhat/terraform-rhcs-rosa-hcp/blob/main/modules/idp/main.tf#L127

# TODO add custom ingress
# https://access.redhat.com/articles/7028653
# https://aws.amazon.com/blogs/containers/implementing-custom-domain-names-with-rosa/
