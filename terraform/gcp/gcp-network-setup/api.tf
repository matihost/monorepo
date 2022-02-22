# containerfilesystem - required by: https://cloud.google.com/kubernetes-engine/docs/how-to/image-streaming

locals {
  apis = ["servicenetworking", "dns"]
}

resource "google_project_service" "apis" {
  count              = length(local.apis)
  service            = "${local.apis[count.index]}.googleapis.com"
  disable_on_destroy = false
}
