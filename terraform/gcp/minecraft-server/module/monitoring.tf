# resource.type="gce_instance"
# AND log_id("syslog")
# AND labels."compute.googleapis.com/resource_name" =~ "prod-02.*"
# AND (jsonPayload.message =~ ".*joined the game.*"  OR jsonPayload.message =~ ".*left the game.*")



resource "google_logging_project_bucket_config" "minecraft" {
    project        = var.project
    location       = "global"
    retention_days = 30
    bucket_id      = "${var.minecraft_server_name}-minecraft"
}

resource "google_logging_project_sink" "minecraft-audit" {
  name        = "${var.minecraft_server_name}-minecraft-audit"
  description = "${var.minecraft_server_name} minecraft audit log"
  destination = "logging.googleapis.com/projects/${var.project}/locations/global/buckets/${google_logging_project_bucket_config.minecraft.bucket_id}"


  filter  = join(" AND ", [
    "resource.type=\"gce_instance\"",
    "log_id(\"syslog\")",
    "labels.\"compute.googleapis.com/resource_name\"=~\"${var.minecraft_server_name}.*\"",
    "(jsonPayload.message =~ \".*joined the game.*\" OR jsonPayload.message =~ \".*left the game.*\")"
  ])

  # TODO for some reason it is not created
  unique_writer_identity = false
  # unique_writer_identity = true
}

# Because our sink uses a unique_writer, we must grant that writer access to the bucket.
# resource "google_project_iam_binding" "minecraft-audit" {
#   project = var.project

#   role = "roles/storage.objectCreator"

#   members = [
#     google_logging_project_sink.minecraft-audit.writer_identity,
#   ]
# }
