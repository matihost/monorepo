resource "google_iam_workload_identity_pool" "pool" {
  provider = google-beta
  project  = var.project

  workload_identity_pool_id = "gh-pool"
  display_name              = "gh-pool"
  description               = "Worflow identity pool for GitHub Actions"
  disabled                  = false

  # Worflow identity pool is in fact undeletable
  # Attempt to delete marks pool as deleted preventing its creation
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_iam_workload_identity_pool_provider" "provider" {
  provider                           = google-beta
  project                            = var.project
  workload_identity_pool_id          = google_iam_workload_identity_pool.pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "gh-pool-provider"
  display_name                       = "gh-pool-provider"
  description                        = "Workload Identity Pool Provider for GitHub Actions"
  disabled                           = false
  # GitHub OIDC
  # https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#understanding-the-oidc-token
  attribute_mapping = {
    "attribute.actor" : "assertion.actor",
    "attribute.aud" : "assertion.aud",
    "attribute.repository" : "assertion.repository",
    "attribute.repository_owner" : "assertion.repository",
    "google.subject" : "assertion.sub"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  # Worflow identity pool is in fact undeletable
  # Attempt to delete marks pool as deleted preventing its creation
  lifecycle {
    prevent_destroy = true
  }
}
