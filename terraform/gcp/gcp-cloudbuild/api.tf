locals {
  apis = ["cloudbuild", "secretmanager", "artifactregistry", "clouddeploy", ]
}

resource "google_project_service" "apis" {
  count              = length(local.apis)
  service            = "${local.apis[count.index]}.googleapis.com"
  disable_on_destroy = false
}
