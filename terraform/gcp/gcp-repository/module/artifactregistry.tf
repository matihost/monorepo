resource "google_artifact_registry_repository" "docker" {
  for_each = toset(var.regions)

  location      = each.key
  repository_id = "docker"
  description   = "Docker hosted repository"
  format        = "DOCKER"

  docker_config {
    immutable_tags = false
  }
}
