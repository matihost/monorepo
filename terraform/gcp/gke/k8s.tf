provider "kubernetes" {
  load_config_file = false

  host  = "https://${google_container_cluster.gke.endpoint}"
  token = data.google_client_config.current.access_token
  cluster_ca_certificate = base64decode(
    google_container_cluster.gke.master_auth[0].cluster_ca_certificate,
  )
}

provider "helm" {
  kubernetes {
    host  = "https://${google_container_cluster.gke.endpoint}"
    token = data.google_client_config.current.access_token
    cluster_ca_certificate = base64decode(
      google_container_cluster.gke.master_auth[0].cluster_ca_certificate,
    )
  }
}

# Deploy GKE K8S cluster configuration like restricted PSP, clusterroles, network policies etc.
resource "helm_release" "cluster-config" {
  name  = "cluster-config"
  chart = "${path.module}/cluster-config"

  namespace        = "cluster-config"
  create_namespace = true

  depends_on = [
    google_container_cluster.gke
  ]
}

# Deploy ExternalDNS addon
resource "helm_release" "external-dns" {
  # Ensure deployment starts when GKE Node Pool is provisioned
  depends_on = [
    google_container_cluster.gke,
    google_container_node_pool.gke_nodes
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
