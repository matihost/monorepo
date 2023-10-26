# cloudscheduler puts event on pubsub which is read by cloudfunctions

locals {
  scheduler-apis = ["cloudscheduler", "pubsub", "cloudfunctions", "cloudbuild"]
}

resource "google_project_service" "scheduler-apis" {
  count              = length(local.scheduler-apis)
  service            = "${local.scheduler-apis[count.index]}.googleapis.com"
  disable_on_destroy = false
}

resource "google_pubsub_topic" "minecraft-lifecycle-topic" {
  name = "${var.minecraft_server_name}.lifecycle.minecraft.topic"

  depends_on = [
    google_project_service.scheduler-apis
  ]
}

resource "google_cloud_scheduler_job" "stop-cron" {
  name        = "${var.minecraft_server_name}-server-stop-cron"
  description = "Shutdown Minecraft ${var.minecraft_server_name} instance group"
  schedule    = "05 22 * * *"
  time_zone   = "Europe/Warsaw"

  pubsub_target {
    # topic.id is the topic's full resource name.
    topic_name = google_pubsub_topic.minecraft-lifecycle-topic.id
    data       = base64encode("stop")
  }

  depends_on = [
    google_project_service.scheduler-apis
  ]
}

resource "google_cloud_scheduler_job" "start-cron" {
  name        = "${var.minecraft_server_name}-server-start-cron"
  description = "Start Minecraft ${var.minecraft_server_name} instance group"
  schedule    = "05 10 * * *"
  time_zone   = "Europe/Warsaw"

  pubsub_target {
    # topic.id is the topic's full resource name.
    topic_name = google_pubsub_topic.minecraft-lifecycle-topic.id
    data       = base64encode("start")
  }

  # To mitigate error - when Terraform creates two schedulers at the same time
  #Error: Error when reading or editing CloudSchedulerJob "projects/.../locations/.../jobs/...-server-shutdown-cron": googleapi: Error 409: Concurrency error. Try again later.
  #Error: Error when reading or editing CloudSchedulerJob "projects/./locations/.../jobs/...-server-shutdown-cron": googleapi: Error 409: Concurrency error. Try again later.

  depends_on = [
    google_cloud_scheduler_job.stop-cron
  ]
}

resource "null_resource" "scheduler-code" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = <<-EOT
    mkdir -p ${path.module}/target &&
      cp -r scheduler ${path.module}/target/ && cd ${path.module}/target/scheduler &&
      zip -r scheduler.zip * && mv scheduler.zip ..
    EOT
  }
}

resource "google_storage_bucket_object" "minecraft-code" {
  name   = "${var.minecraft_server_name}/scheduler.zip"
  source = "${path.module}/target/scheduler.zip"
  bucket = google_storage_bucket.minecraft-data.name

  depends_on = [null_resource.scheduler-code]
}

# TODO migrate to google_cloudfunctions2_function
resource "google_cloudfunctions_function" "minecraft-lifecycle-executor" {
  name        = "${var.minecraft_server_name}-minecraft-lifecycle-executor"
  description = "Minecraft server ${var.minecraft_server_name} lifecycle executor"
  # supported runtimes versions:
  # https://cloud.google.com/functions/docs/concepts/execution-environment#runtimes
  runtime     = "go121"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.minecraft-data.name
  source_archive_object = google_storage_bucket_object.minecraft-code.name


  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.minecraft-lifecycle-topic.id
  }

  timeout     = 60
  entry_point = "Handle"

  labels = {
    purpose = "lifecycle"
  }

  environment_variables = {
    MINECRAFT_SERVER_NAME = google_compute_instance_group_manager.minecraft_group_manager.name
    GCP_ZONE              = var.zone
    GCP_PROJECT_ID        = var.project
  }

  service_account_email = google_service_account.minecraft-scheduler.email
}

resource "google_service_account" "minecraft-scheduler" {
  account_id   = "${var.minecraft_server_name}-minecraft-scheduler-sa"
  display_name = "Service account for Minecraft ${var.minecraft_server_name} scheduler instance"
}


# allows to update instangeGroupManager settings
resource "google_project_iam_member" "minecraft-scheduler-instanceAdmin" {
  project = var.project


  # Use custom role created by gcp-iam terraform
  role = "projects/${var.project}/roles/instanceGroupUpdater"
  # or use predefined bigger role
  # role   = "roles/compute.instanceAdmin"

  member = "serviceAccount:${google_service_account.minecraft-scheduler.email}"
}

# # IAM entry for a single user to invoke the function
# resource "google_cloudfunctions_function_iam_member" "invoker" {
#   project        = google_cloudfunctions_function.function.project
#   region         = google_cloudfunctions_function.function.region
#   cloud_function = google_cloudfunctions_function.function.name

#   role   = "roles/cloudfunctions.invoker"
#   member = "user:myFunctionInvoker@example.com"
# }
