// Service Account which is used by GKE Nodes
resource "google_service_account" "gke-sa" {
  account_id   = "${local.gke_name}-gke-sa"
  display_name = "Service Account which is used by GKE Nodes"
}

resource "google_project_iam_member" "gke-log-writer" {
  role   = "roles/logging.logWriter"
  member = "serviceAccount:${google_service_account.gke-sa.email}"
}

resource "google_project_iam_member" "gke-metrics-writer" {
  role   = "roles/monitoring.metricWriter"
  member = "serviceAccount:${google_service_account.gke-sa.email}"
}

# also needed to send metrics, permits write-only access to resource metadata provide permissions needed by agents to send metadata
resource "google_project_iam_member" "gke-metrics-metadata-writer" {
  role   = "roles/stackdriver.resourceMetadata.writer"
  member = "serviceAccount:${google_service_account.gke-sa.email}"
}


# so that  GKE cluster can access images from its own GCP project (gcr.io/project-id)
resource "google_project_iam_member" "gke-gcr-access" {
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.gke-sa.email}"
}

# so that  GKE cluster can access GCP Artifacts
resource "google_project_iam_member" "gke-artifacts-access" {
  role   = "roles/artifactregistry.reader"
  member = "serviceAccount:${google_service_account.gke-sa.email}"
}

// Service Account used by External DNS workflow on GKE
resource "google_service_account" "edns-sa" {
  account_id   = "${local.gke_name}-edns-sa"
  display_name = "Service Account which is used by ExternalDNS workflow in GKE"
}

resource "google_project_iam_member" "edns-dnsadmin" {
  role   = "roles/dns.admin"
  member = "serviceAccount:${google_service_account.edns-sa.email}"
}

// Make an IAM policy that allows the K8S SA to be a workload identity user
data "google_iam_policy" "edns_gsa2k8ssa" {
  binding {
    role = "roles/iam.workloadIdentityUser"
    members = [
      format("serviceAccount:%s.svc.id.goog[%s/%s]", var.project, var.external_dns_k8s_namespace, var.external_dns_k8s_sa_name)
    ]
  }
}

// Bind the workload identity IAM policy to the GSA
resource "google_service_account_iam_policy" "edns_gsa2k8ssa" {
  service_account_id = google_service_account.edns-sa.name
  policy_data        = data.google_iam_policy.edns_gsa2k8ssa.policy_data
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
