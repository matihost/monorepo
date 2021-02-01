locals {
  anthos-apis = ["gkeconnect", "gkehub", "anthos", "multiclusteringress", "cloudresourcemanager"]
}

resource "google_project_service" "anthos-api" {
  count              = length(local.anthos-apis)
  service            = "${local.anthos-apis[count.index]}.googleapis.com"
  disable_on_destroy = false
}
