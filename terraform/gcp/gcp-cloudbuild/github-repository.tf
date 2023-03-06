resource "google_cloudbuildv2_repository" "github-repository" {
  provider = google-beta
  project  = var.project
  location = var.region

  name              = var.gh_repo_name
  parent_connection = google_cloudbuildv2_connection.github-connection.name
  remote_uri        = "https://github.com/${var.gh_repo_owner}/${var.gh_repo_name}.git"
}



resource "google_cloudbuild_trigger" "push-build-trigger" {
  provider = google-beta

  project     = var.project
  location    = var.region
  name        = "on-push2${var.gh_repo_name}-${var.gh_repo_owner}"
  description = "On push to https://github.com/${var.gh_repo_owner}/${var.gh_repo_name}.git"
  repository_event_config {
    repository = google_cloudbuildv2_repository.github-repository.id
    push {
      branch = ".*"
    }
  }

  filename = "cloudbuild.yaml"
}
