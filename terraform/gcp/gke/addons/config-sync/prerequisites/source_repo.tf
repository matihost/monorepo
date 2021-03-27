resource "google_project_service" "source-api" {
  service            = "sourcerepo.googleapis.com"
  disable_on_destroy = false
}

resource "google_sourcerepo_repository" "config-sync-repo" {
  name = "gke-config"
  depends_on = [
    google_project_service.source-api
  ]
}
