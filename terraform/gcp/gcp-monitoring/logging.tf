# Logging buckets are automatically created for a given folder, project, organization, billingAccount and cannot be deleted.
# Creating a resource of this type will acquire and update the resource that already exists at the desired location.
# These buckets cannot be removed so deleting this resource will remove the bucket config from your terraform state but will leave the logging bucket unchanged.
# The buckets that are currently automatically created are "_Default" and "_Required".
resource "google_logging_project_bucket_config" "basic" {
  project = var.project

  location       = "global"
  bucket_id      = "_Default"
  retention_days = 2
}

resource "google_logging_project_exclusion" "gce-ops-agent-logs-exclusion" {
  project = var.project

  name        = "gce-ops-agent-logs-exclusion"
  description = "Exclude google-cloud-ops-agent from GCE instancess"

  filter = <<-EOF
  resource.type="gce_instance"
  severity=DEFAULT
  log_name=~"logs/syslog$"
  jsonPayload.message=~"otelopscol"
  EOF
}

resource "google_logging_project_exclusion" "gce-serial-console-logs-exclusion" {
  project = var.project

  name        = "gce-serial-console-logs-exclusion"
  description = "Exclude GKE gce-serial-console logs"

  filter = <<-EOF
  resource.type="gce_instance"
  log_name=~".*/logs/serialconsole.googleapis.com.*"
  severity=("DEBUG" OR "INFO")
  EOF
}
