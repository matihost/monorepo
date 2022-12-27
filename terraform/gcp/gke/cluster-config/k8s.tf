resource "google_certificate_manager_certificate_map" "gke-external-gtw-cert-map" {
  name        = "gke-${local.gke_name}-gxlb"
  description = "Certificate map for GKE ${local.gke_name} K8S Gateway gateway/external"
  labels = {
    "k8s_namespace" : "gateway",
    "k8s_gateway_name" : "external"
  }
}

data "local_file" "gxlb-crt-file" {
  filename = "${path.module}/target/gxlb.crt"

  depends_on = [
    null_resource.cluster-config-script,
  ]
}

data "local_file" "gxlb-key-file" {
  filename = "${path.module}/target/gxlb.key"

  depends_on = [
    null_resource.cluster-config-script,
  ]
}


resource "google_certificate_manager_certificate" "wild-gxlb-gke-tls" {
  name        = "wild-gxlb-gke-${var.cluster_name}-${var.env}"
  description = "Self signed Certificate for CN: *.gxlb.gke.${var.cluster_name}.${var.env}.gcp.testing."
  self_managed {
    pem_certificate = data.local_file.gxlb-crt-file.content
    pem_private_key = data.local_file.gxlb-key-file.content
  }
}

resource "google_certificate_manager_certificate_map_entry" "wild-gxlb-gke-tls-entry" {
  name         = "wild-gxlb-gke-${var.cluster_name}-${var.env}-"
  description  = "My acceptance test certificate map entry"
  map          = google_certificate_manager_certificate_map.gke-external-gtw-cert-map.name
  hostname     = "*.gxlb.gke.${var.cluster_name}.${var.env}.gcp.testing"
  certificates = [google_certificate_manager_certificate.wild-gxlb-gke-tls.id]
}

resource "null_resource" "cluster-config-script" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "${path.module}/cluster-config.sh ${path.module}/target/${local.gke_name}/kubeconfig '*.gxlb.gke.${var.cluster_name}.${var.env}.gcp.testing'"
  }

}

# Deploy GKE K8S cluster configuration like restricted PSP, clusterroles, network policies, API Gateway etc.
resource "helm_release" "cluster-config" {
  name  = "cluster-config"
  chart = "${path.module}/cluster-config-chart"

  namespace        = "cluster-config"
  create_namespace = true

  values = [
    templatefile("${path.module}/cluster-config.template.yaml", {
      GCP_PROJECT      = var.project,
      GCP_CLUSTER_NAME = var.cluster_name,
      GCP_ENV          = var.env,
      }
    )
  ]

  depends_on = [
    google_certificate_manager_certificate_map_entry.wild-gxlb-gke-tls-entry,
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

  depends_on = [
    helm_release.cluster-config
  ]
}
