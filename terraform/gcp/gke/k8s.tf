
module "gke_auth" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  version = ">= 19"

  project_id   = var.project
  cluster_name = local.gke_name
  location     = local.location

  depends_on = [
    google_container_cluster.gke
  ]
}
resource "local_file" "kubeconfig" {
  content  = module.gke_auth.kubeconfig_raw
  filename = "${path.module}/target/${local.gke_name}/kubeconfig"
}

# Normally Kubernetes and Helm could be init via
# But when K8S TF is used when TF is created it leads to error upon second run
# https://itnext.io/terraform-dont-use-kubernetes-provider-with-your-cluster-resource-d8ec5319d14a
#
# data "google_container_cluster" "my_cluster" {
#   name     = local.gke_name
#   location = local.location
# }
# provider "kubernetes" {
#   load_config_file = false

#   host  = "https://${data.google_container_cluster.gke.endpoint}"
#   token = data.google_client_config.current.access_token
#   cluster_ca_certificate = base64decode(
#     data.google_container_cluster.gke.master_auth[0].cluster_ca_certificate,
#   )
# }

# provider "helm" {
#   kubernetes {
#     host  = "https://${data.google_container_cluster.gke.endpoint}"
#     token = data.google_client_config.current.access_token
#     cluster_ca_certificate = base64decode(
#       data.google_container_cluster.gke.master_auth[0].cluster_ca_certificate,
#     )
#   }
# }

provider "kubernetes" {
  config_paths = ["${path.module}/target/${local.gke_name}/kubeconfig", "~/.kube/config"]
}

provider "helm" {
  kubernetes {
    config_paths = ["${path.module}/target/${local.gke_name}/kubeconfig", "~/.kube/config"]
  }
}


resource "null_resource" "cluster-config-script" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "${path.module}/cluster-config/cluster-config.sh ${path.module}/target/${local.gke_name}/kubeconfig"
  }

  depends_on = [
    google_container_cluster.gke,
    local_file.kubeconfig
  ]
}

# Deploy GKE K8S cluster configuration like restricted PSP, clusterroles, network policies etc.
resource "helm_release" "cluster-config" {
  name  = "cluster-config"
  chart = "${path.module}/cluster-config"

  namespace        = "cluster-config"
  create_namespace = true

  depends_on = [
    null_resource.cluster-config-script,
  ]
}

# Deploy ExternalDNS addon
resource "helm_release" "external-dns" {
  # Ensure deployment starts when GKE Node Pool is provisioned
  depends_on = [
    google_container_cluster.gke,
    google_container_node_pool.gke_nodes,
  ]
  wait       = true
  timeout    = 360
  name       = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  # version    = "..."

  namespace        = "external-dns"
  create_namespace = true

  values = [
    templatefile("${path.module}/external-dns.template.yaml", {
      GCP_PROJECT = var.project,
      GCP_GSA     = google_service_account.edns-sa.account_id,
      }
    )
  ]
}
