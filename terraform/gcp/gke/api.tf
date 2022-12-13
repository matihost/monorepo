# containerfilesystem - required by: https://cloud.google.com/kubernetes-engine/docs/how-to/image-streaming
# file - FileStore - required by Filestore CSI driver (aka google_container_cluster.addons.gcp_filestore_csi_driver_config )
locals {
  gke-apis = ["container", "containerfilesystem", "file", "containersecurity"]
}

resource "google_project_service" "gke-apis" {
  count              = length(local.gke-apis)
  service            = "${local.gke-apis[count.index]}.googleapis.com"
  disable_on_destroy = false
}
