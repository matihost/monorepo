resource "ibm_resource_instance" "logs" {
  resource_group_id = local.resource_group_id

  name = "${local.prefix}-instances-logs"

  service  = "logdna"
  plan     = "7-day"
  location = var.region
  # tags              = ....
  service_endpoints = "public-and-private"

  parameters = {
    "default_receiver" = false
  }
}


# IBM Cloud Logging key (LogDna).
resource "ibm_resource_key" "logs-key" {
  name                 = "${local.prefix}-instances-logs-manager"
  resource_instance_id = ibm_resource_instance.logs.id
  role                 = "Manager"
  # tags                 = ...
}



output "logs_ingestion_key" {
  value       = ibm_resource_key.logs-key.credentials.ingestion_key
  description = "Log Analysis ingest key for agents on VM instances to use"
  sensitive   = true
}
