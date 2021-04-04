data "google_service_account" "configsync-sa" {
  account_id = "gke-config-sync-sa"
}


data "google_storage_bucket_object_content" "config-sync-operator-gs-content" {
  name   = "released/latest/config-sync-operator.yaml"
  bucket = "config-management-release"
}

resource "local_file" "config-sync-operator-yaml" {
  content  = data.google_storage_bucket_object_content.config-sync-operator-gs-content.content
  filename = "${path.module}/target/config-sync-operator.yaml"
}

resource "local_file" "config-sync-configuration-yaml" {
  content = templatefile("${path.module}/config-management.template.yaml", {
    CLUSTER_NAME = local.gke_name,
    SYNC_REPO    = "https://source.developers.google.com/p/${var.project}/r/gke-config"
  })
  filename = "${path.module}/target/config-management.yaml"
}


resource "null_resource" "config-sync-install" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "${path.module}/config-sync.sh ${data.google_service_account.configsync-sa.email} ${var.project}"
  }

  depends_on = [
    local_file.config-sync-operator-yaml,
    local_file.kubeconfig
  ]
}
