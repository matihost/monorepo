locals{
  default_ocp_version = "${data.ibm_container_cluster_versions.cluster_versions.default_openshift_version}_openshift"
}


data "ibm_is_vpc" "vpc" {
  name = var.vpc_name
}

data "ibm_is_subnet" "subnet" {
  for_each = var.subnetworks

  vpc  = data.ibm_is_vpc.vpc.id
  name = each.value.name
}


# Lookup the current default kube version
data "ibm_container_cluster_versions" "cluster_versions" {
  resource_group_id = var.resource_group_id
}

resource "ibm_container_vpc_cluster" "ocp" {
  resource_group_id               = var.resource_group_id

  name                            = local.prefix
  vpc_id                          = data.ibm_is_vpc.vpc.id
  # TODO taggin
  # tags                            = var.tags
  kube_version                    = local.default_ocp_version
  flavor                          = var.instance_profile
  # empty means w/o licence, obtaining one automatically (more expensive)
  # entitlement                     = "cloud_pak"
  cos_instance_crn                = ibm_resource_instance.cos.id
  worker_count                    = 1
  wait_till                       = "IngressReady"
  force_delete_storage            = true
  disable_public_service_endpoint = false
  # TODO define labels
  # worker_labels                   = local.default_pool.labels
  # TODO kms
  # crk                             = default pool boot volume encryption kms config crk
  # kms_instance_id                 = default pool boot volume encryption kms config kms_instance_id
  # kms_account_id                  = default pool boot volume encryption kms config kms_account_id

  # TODO define security groups
  # security_groups = local.cluster_security_groups

  lifecycle {
    ignore_changes = [worker_count, kube_version]
  }

  # default workers are mapped to the subnets that are "private"
  dynamic "zones" {
    for_each = var.subnetworks
    content {
      subnet_id = data.ibm_is_subnet.subnet[zones.key].id
      name      = zones.key
    }
  }

  # TODO KMS integration
  # dynamic "kms_config" {
  #   for_each = var.kms_config != null ? [1] : []
  #   content {
  #     crk_id           = kms config crk_id
  #     instance_id      = kms config instance_id
  #     private_endpoint = kms config private_endpoint
  #     account_id       = kms config account_id
  #   }
  # }

  timeouts {
    delete = "2h"
    create = "3h"
    update = "3h"
  }
}


# TODO add more worker pools

# To get current versions run:
# ibmcloud ks cluster addon versions
#
# Need to explicitely list all version even when documentation claims it is optional
# When version is not provide, initial creation may be successful, but change will notice to remove old and install new
# leading to error
resource "ibm_container_addons" "addons" {
  depends_on = [ ibm_container_vpc_cluster.ocp ]

  cluster = ibm_container_vpc_cluster.ocp.name

  manage_all_addons = true

  # CSI driver is only mandatory addon
  addons {
    name    = "vpc-block-csi-driver"
    version = "5.1"
  }

  addons {
    name    = "debug-tool"
    version = "2.0.0"
  }

  addons {
    name    = "vpc-file-csi-driver"
    version = "1.2"
  }

  addons {
    name    = "cluster-autoscaler"
    version = "1.2.0"
  }

  addons {
    name    = "static-route"
    version = "1.0.0"
  }

  addons {
    name    = "image-key-synchronizer"
    version = "1.0.0"
  }

  # https://cloud.ibm.com/docs/containers?topic=containers-istio&interface=ui#istio_install
  # Error: 'istio' configuration is not supported on OpenShift clusters.
  #
  # addons {
  #   name    = "istio"
  #   version = "1.20"
  # }

  # Error: 'alb-oauth-proxy' configuration is not supported on OpenShift clusters.
  #
  # addons {
  #   name    = "alb-oauth-proxy"
  #   version = "2.0.0"
  # }

  # https://cloud.ibm.com/docs/openshift?topic=openshift-deploy-odf-vpc
  # addons {
  #   name = "openshift-data-foundation"
  #   version = "1.2.0"
  #   # parameters_json = <<PARAMETERS_JSON
  #   #     {
  #   #         "osdSize":"200Gi",
  #   #         "numOfOsd":"2",
  #   #         "osdStorageClassName":"ibmc-vpc-block-metro-10iops-tier",
  #   #         "odfDeploy":"true"
  #   #     }
  #   #     PARAMETERS_JSON
  # }

  timeouts {
    create = "3h"
    update = "3h"
  }
}
