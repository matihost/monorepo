resource "ibm_resource_instance" "logs" {
  resource_group_id = var.resource_group_id

  name              = "${local.prefix}-logs"

  service           = "logdna"
  plan              = "7-day"
  location          = var.region
  # tags              = ....
  service_endpoints = "public-and-private"

  parameters = {
    "default_receiver" = false
  }
}


# IBM Cloud Logging key (LogDna).
resource "ibm_resource_key" "logs-key" {
  name                 = "${local.prefix}-logs-manager"
  resource_instance_id = ibm_resource_instance.logs.id
  role                 = "Manager"
  # tags                 = ...
}


resource "ibm_resource_instance" "monitoring" {
  resource_group_id = var.resource_group_id

  name              = "${local.prefix}-monitoring"
  service           = "sysdig-monitor"
  plan              = "graduated-tier"
  location          = var.region
  # tags              = ...
  service_endpoints = "public-and-private"

  parameters = {
    "default_receiver" = false
  }
}

# IBM Cloud Monitoring access key (Sysdig)
resource "ibm_resource_key" "monitoring-key" {
  name                 = "${local.prefix}-monitoring-manager"

  resource_instance_id = ibm_resource_instance.monitoring.id
  role                 = "Manager"
  # tags                 = ...
}


output "logs_ingestion_key" {
  value       = ibm_resource_key.logs-key.credentials.ingestion_key
  description = "Log Analysis ingest key for agents to use"
  sensitive   = true
}


output "cloud_monitoring_access_key" {
  value       = ibm_resource_key.monitoring-key.credentials["Sysdig Access Key"]
  description = "IBM cloud monitoring access key for agents to use"
  sensitive   = true
}

resource "null_resource" "deploy-log-agent" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "${path.module}/deploy-log-agent.sh ${ibm_resource_key.logs-key.credentials.ingestion_key}"
  }

  depends_on = [
   ibm_resource_key.logs-key,
  ]
}
