# cloudscheduler puts event on pubsub which is read by cloudfunctions

locals {
  gke-apis = ["cloudscheduler", "pubsub", "cloudfunctions"]
}

resource "google_project_service" "required-apis" {
  count              = length(local.gke-apis)
  service            = "${local.gke-apis[count.index]}.googleapis.com"
  disable_on_destroy = false
}
