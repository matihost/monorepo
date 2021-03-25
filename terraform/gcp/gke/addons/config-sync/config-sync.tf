data "google_storage_bucket_object_content" "config-sync-operator-gs-content" {
  name   = "released/latest/config-sync-operator.yaml"
  bucket = "config-management-release"
}

resource "local_file" "config-sync-operator-yaml" {
  content  = data.google_storage_bucket_object_content.config-sync-operator-gs-content.content
  filename = "${path.module}/target/config-sync-operator.yaml"
}

resource "null_resource" "config-sync-install" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "${path.module}/config-sync.sh serviceAccount:${google_service_account.configsync-sa.email}"
  }

  depends_on = [
    local_file.config-sync-operator-yaml
  ]
}
