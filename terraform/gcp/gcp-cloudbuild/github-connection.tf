resource "google_secret_manager_secret" "github-token-secret" {
  provider  = google-beta
  project   = var.project
  secret_id = "github-token-secret"

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "github-token-secret-version" {
  provider = google-beta

  secret      = google_secret_manager_secret.github-token-secret.id
  secret_data = var.gh_token
}

data "google_iam_policy" "p4sa-secretAccessor" {
  provider = google-beta
  binding {
    role    = "roles/secretmanager.secretAccessor"
    members = ["serviceAccount:service-${data.google_project.current.number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"]
  }
}

resource "google_secret_manager_secret_iam_policy" "policy" {
  provider    = google-beta
  project     = var.project
  secret_id   = google_secret_manager_secret.github-token-secret.secret_id
  policy_data = data.google_iam_policy.p4sa-secretAccessor.policy_data
}

resource "google_cloudbuildv2_connection" "github-connection" {
  provider = google-beta
  project  = var.project
  location = var.region
  name     = "${var.gh_repo_owner}-gh-connection"

  github_config {
    app_installation_id = var.gh_cloud_build_app_id
    #
    authorizer_credential {
      oauth_token_secret_version = google_secret_manager_secret_version.github-token-secret-version.id
    }
  }
}
