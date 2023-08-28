resource "google_artifact_registry_repository" "docker" {
  location      = var.region
  repository_id = "docker"
  description   = "Docker hosted repository"
  format        = "DOCKER"

  docker_config {
    immutable_tags = false
  }
}
