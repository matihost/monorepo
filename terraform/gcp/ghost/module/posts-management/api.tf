locals {
  required-apis = ["cloudfunctions", "artifactregistry", "cloudbuild"]
}

resource "google_project_service" "required" {
  count              = length(local.required-apis)
  service            = "${local.required-apis[count.index]}.googleapis.com"
  disable_on_destroy = false
}
