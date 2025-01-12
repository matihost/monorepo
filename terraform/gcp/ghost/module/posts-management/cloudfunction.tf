#TODO add trigger to cloud function, the one desired by client, disable default https etc.
#TODO use Secret to pass secretly Ghost keys to Cloud Function

# Assuming admin_ghost is the one in main region
data "google_cloud_run_service" "admin_ghost" {
  name     = "${local.name}-${var.region}"
  location = var.region
}


resource "google_storage_bucket" "bucket" {
  name     = "${local.name}-gcf-source"
  location = var.region

  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "object" {
  name   = "function-source.zip"
  bucket = google_storage_bucket.bucket.name
  source = "target/function-source.zip"

  depends_on = [null_resource.function-code]
}


resource "null_resource" "function-code" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = <<-EOT
    mkdir -p target && zip target/function-source.zip index.js package.json
    EOT
  }
}


resource "google_cloudfunctions2_function" "removeAllPosts" {
  name        = "${local.name}-remove-posts"
  location    = var.region
  description = "Function to remove all posts"

  build_config {
    # supported runtimes versions:
    # https://cloud.google.com/functions/docs/concepts/execution-environment#runtimes
    runtime     = "nodejs22"
    entry_point = "removeAllPosts"
    source {
      storage_source {
        bucket = google_storage_bucket.bucket.name
        object = google_storage_bucket_object.object.name
      }
    }
  }

  service_config {
    environment_variables = {
      "GHOST_URL"         = data.google_cloud_run_service.admin_ghost.status[0].url,
      "GHOST_ADMIN_KEY"   = var.ghost_admin_key,
      "GHOST_CONTENT_KEY" = var.ghost_content_key,
    }
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60

    service_account_email = google_service_account.ghost-cf.email
  }


  depends_on = [null_resource.function-code, google_project_service.required]
}
