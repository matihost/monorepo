locals {
  private_subnet_ids = [for subnet in data.aws_subnet.private : subnet.id]
  installer_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.prefix}-HCP-ROSA-Installer-Role"
  sts_roles = {
    role_arn         = local.installer_role_arn,
    support_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.prefix}-HCP-ROSA-Support-Role",
    instance_iam_roles = {
      worker_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.prefix}-HCP-ROSA-Worker-Role"
    },
    operator_role_prefix = local.prefix,
    oidc_config_id       = rhcs_rosa_oidc_config.oidc_config.id
  }
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
  sts                    = local.sts_roles

  availability_zones       = var.zones
  replicas                 = var.replicas
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
    ignore_changes = [create_admin_user, admin_credentials, replicas]
  }
}


# TODO add autoscaller
resource "rhcs_hcp_cluster_autoscaler" "cluster_autoscaler" {
  count = var.enable_cluster_autoscaler ? 1 : 0

  cluster                 = rhcs_cluster_rosa_hcp.rosa_hcp_cluster.id
  max_pod_grace_period    = var.autoscaler_max_pod_grace_period
  pod_priority_threshold  = var.autoscaler_pod_priority_threshold
  max_node_provision_time = var.autoscaler_max_node_provision_time

  resource_limits = {
    max_nodes_total = var.autoscaler_max_nodes_total
  }
}

resource "rhcs_hcp_default_ingress" "default_ingress" {
  cluster          = rhcs_cluster_rosa_hcp.rosa_hcp_cluster.id
  listening_method = "internal"
}


resource "rhcs_kubeletconfig" "kubeletconfig" {
  cluster        = rhcs_cluster_rosa_hcp.rosa_hcp_cluster.id
  pod_pids_limit = var.pod_limit
}

# TODO add own IDP based on Keycloak
# https://registry.terraform.io/providers/terraform-redhat/rhcs/latest/docs/resources/identity_provider#nested-schema-for-openid
# https://github.com/terraform-redhat/terraform-rhcs-rosa-hcp/blob/main/modules/idp/main.tf#L127

# TODO add own worker pool and delete default one
# https://registry.terraform.io/providers/terraform-redhat/rhcs/latest/docs/guides/worker-machine-pool
# https://github.com/terraform-redhat/terraform-rhcs-rosa-hcp/blob/main/modules/machine-pool/main.tf

# TODO add custom ingress
# https://access.redhat.com/articles/7028653
# https://aws.amazon.com/blogs/containers/implementing-custom-domain-names-with-rosa/
