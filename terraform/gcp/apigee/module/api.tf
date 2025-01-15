resource "google_project_service" "apigee" {
  service            = "apigee.googleapis.com"
  disable_on_destroy = false
}
