# containerfilesystem - required by: https://cloud.google.com/kubernetes-engine/docs/how-to/image-streaming

locals {
  gke-apis = ["container", "containerfilesystem"]
}

resource "google_project_service" "gke-apis" {
  count              = length(local.gke-apis)
  service            = "${local.gke-apis[count.index]}.googleapis.com"
  disable_on_destroy = false
}
