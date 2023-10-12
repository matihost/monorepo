# containerfilesystem - required by: https://cloud.google.com/kubernetes-engine/docs/how-to/image-streaming

locals {
  apis = ["cloudkms", ]
}

resource "google_project_service" "kms-apis" {
  count              = length(local.apis)
  service            = "${local.apis[count.index]}.googleapis.com"
  disable_on_destroy = false
}
