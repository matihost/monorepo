resource "google_certificate_manager_certificate_map" "gke-external-gtw-cert-map" {
  name        = "gke-${local.gke_name}-gxlb"
  description = "Certificate map for GKE ${local.gke_name} K8S Gateway gateway/external"
  labels = {
    "k8s_namespace" : "gateway",
    "k8s_gateway_name" : "external"
  }
}


resource "google_certificate_manager_certificate" "wild-gxlb-gke-tls" {
  name        = "wild-gxlb-gke-${var.cluster_name}-${var.env}"
  description = "Self signed Certificate for CN: ${var.external_gateway.cn}."
  self_managed {
    pem_certificate = var.external_gateway.tls_crt
    pem_private_key = var.external_gateway.tls_key
  }
}

resource "google_certificate_manager_certificate_map_entry" "wild-gxlb-gke-tls-entry" {
  name         = "wild-gxlb-gke-${var.cluster_name}-${var.env}-"
  description  = "My acceptance test certificate map entry"
  map          = google_certificate_manager_certificate_map.gke-external-gtw-cert-map.name
  hostname     = var.external_gateway.cn
  certificates = [google_certificate_manager_certificate.wild-gxlb-gke-tls.id]
}

// Service Account used by External DNS workflow on GKE
resource "google_service_account" "edns-sa" {
  account_id   = "${local.gke_name}-edns-sa"
  display_name = "Service Account which is used by ExternalDNS workflow in GKE"
}

resource "google_project_iam_member" "edns-dnsadmin" {
  project = var.project

  role   = "roles/dns.admin"
  member = "serviceAccount:${google_service_account.edns-sa.email}"
}

# WorkloadIdentity of external-dns KSA to act as GSA
resource "google_service_account_iam_member" "edns_gsa2k8ssa" {
  service_account_id = google_service_account.edns-sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principal://iam.googleapis.com/projects/${data.google_project.current.number}/locations/global/workloadIdentityPools/${var.project}.svc.id.goog/subject/ns/${var.external_dns_k8s_namespace}/sa/${var.external_dns_k8s_sa_name}"
}


# Still requires to annotate KSA to use GSA from K8S level:
# kubectl annotate serviceaccount \
#   --namespace k8s-namespace \
#   ksa-name \
#   iam.gke.io/gcp-service-account=gsa-name@project-id.iam.gserviceaccount.com
# Aka:
# kubectl annotate serviceaccount \
#   --namespace external-dns \
#   external-dns \
#   iam.gke.io/gcp-service-account=edns-sa@matihost.iam.gserviceaccount.com



resource "null_resource" "cluster-config" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "${path.module}/configure-cluster.sh '${var.project}' '${var.cluster_name}' '${local.gke_name}' '${local.location}' '${var.env}' '*.gxlb.gke.${var.cluster_name}.${var.env}.gcp.testing' '${google_service_account.edns-sa.account_id}'"
  }

  depends_on = [
    google_certificate_manager_certificate_map_entry.wild-gxlb-gke-tls-entry,
    google_container_cluster.gke,
    google_container_node_pool.gke_nodes
  ]
}




# data "google_service_account" "edns-sa" {
#   account_id = "${local.gke_name}-edns-sa"
# }

# # Deploy ExternalDNS addon
# resource "helm_release" "external-dns" {
#   wait       = true
#   timeout    = 360
#   name       = "external-dns"
#   repository = "https://charts.bitnami.com/bitnami"
#   chart      = "external-dns"
#   # version    = "..."

#   namespace        = "external-dns"
#   create_namespace = true

#   values = [
#     templatefile("${path.module}/external-dns.template.yaml", {
#       GCP_PROJECT = var.project,
#       GCP_GSA     = data.google_service_account.edns-sa.account_id,
#       }
#     )
#   ]

#   depends_on = [
#     helm_release.cluster-config
#   ]
# }
