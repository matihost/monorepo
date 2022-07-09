




resource "null_resource" "cluster-config-script" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "${path.module}/cluster-config.sh ${path.module}/target/${local.gke_name}/kubeconfig"
  }

  depends_on = [
    local_file.kubeconfig
  ]
}

# Deploy GKE K8S cluster configuration like restricted PSP, clusterroles, network policies etc.
resource "helm_release" "cluster-config" {
  name  = "cluster-config"
  chart = "${path.module}/cluster-config-chart"

  namespace        = "cluster-config"
  create_namespace = true

  depends_on = [
    null_resource.cluster-config-script,
  ]
}


data "google_service_account" "edns-sa" {
  account_id = "${local.gke_name}-edns-sa"
}

# Deploy ExternalDNS addon
resource "helm_release" "external-dns" {
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
      GCP_GSA     = data.google_service_account.edns-sa.account_id,
      }
    )
  ]
}
