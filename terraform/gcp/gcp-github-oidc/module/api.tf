locals {
  apis = ["iam", "cloudresourcemanager", "iamcredentials", "sts", ]
}

resource "google_project_service" "apis" {
  count              = length(local.apis)
  service            = "${local.apis[count.index]}.googleapis.com"
  disable_on_destroy = false
}
