# GSA for Worflow Identity and Config Connector purposes
resource "google_service_account" "identity-workflow-sa" {
  account_id   = "${local.gke_name}-${substr(var.kns, 0, 10)}-wsa"
  display_name = "Service Account which is used by KSA in ns ${var.kns} workflows in GKE ${local.gke_name}"
}

# Logging writing always add
resource "google_project_iam_member" "identity-workflow-sa-logging-role" {
  project = var.project

  role   = "roles/logging.logWriter"
  member = "serviceAccount:${google_service_account.identity-workflow-sa.email}"
}

# Metrics writing always add
resource "google_project_iam_member" "identity-workflow-sa-metric-role" {
  project = var.project

  role   = "roles/monitoring.metricWriter"
  member = "serviceAccount:${google_service_account.identity-workflow-sa.email}"
}

# Traces writing always add
resource "google_project_iam_member" "identity-workflow-sa-trace-role" {
  project = var.project

  role   = "roles/cloudtrace.agent"
  member = "serviceAccount:${google_service_account.identity-workflow-sa.email}"
}

# Assing other roles to GSA
resource "google_project_iam_member" "identity-workflow-sa-role" {
  for_each = toset(var.gsa_roles)

  project = var.project
  role    = each.key
  member  = "serviceAccount:${google_service_account.identity-workflow-sa.email}"
}

# WorkloadIdentity for ConfigConnector in Namespaced mode
resource "google_service_account_iam_member" "configconnector-workflow" {
  service_account_id = google_service_account.identity-workflow-sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = format("serviceAccount:%s.svc.id.goog[%s/%s]", var.project, "cnrm-system", "cnrm-controller-manager-${var.kns}")
}

# WorkloadIdentity for KNS KSAS
resource "google_service_account_iam_member" "ksa-workflow" {
  for_each           = toset(var.kns_sas)
  service_account_id = google_service_account.identity-workflow-sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = format("serviceAccount:%s.svc.id.goog[%s/%s]", var.project, var.kns, each.key)
}


resource "local_file" "config-connector-yaml" {
  content = templatefile("${path.module}/config-connector.template.yaml", {
    KNS = var.kns,
    GSA = google_service_account.identity-workflow-sa.email
  })
  filename = "${path.module}/target/config-connector.yaml"
}

# configure ConfigConnector Context for KNS and apply add
resource "null_resource" "config-connector-context-config" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "${path.module}/config-connector.sh ${google_service_account.identity-workflow-sa.email} ${var.project} ${var.kns} \"${join(" ", var.kns_sas)}\""
  }

  depends_on = [
    google_service_account_iam_member.configconnector-workflow,
    local_file.config-connector-yaml,
    local_file.kubeconfig
  ]
}
