data "google_container_engine_versions" "rapid" {
  provider = google-beta
  // version differ per region or zonal cluster
  location       = var.regional_cluster ? var.region : local.zone
  version_prefix = "1.18."

  project = var.project
}

resource "google_container_cluster" "gke" {
  provider = google-beta

  name        = local.gke_name
  description = "GKE Cluster ${local.gke_name}"
  # When zone, provided cluster is zonal, when region provider cluster is redional.
  # Regional cluster has a charge fee.
  location = var.regional_cluster ? var.region : local.zone

  // network and subnetwork, for Shared VPC, set this to the self link of the shared network.
  network    = google_compute_network.private-gke.name
  subnetwork = google_compute_subnetwork.private-gke.name

  project = var.project

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  addons_config {
    http_load_balancing {
      disabled = false
    }

    horizontal_pod_autoscaling {
      disabled = false
    }

    network_policy_config {
      disabled = false
    }
    dns_cache_config {
      enabled = true
    }
    gce_persistent_disk_csi_driver_config {
      enabled = true
    }
    config_connector_config {
      enabled = true
    }
  }

  network_policy {
    enabled = true
  }


  cluster_autoscaling {
    enabled = true
    resource_limits {
      resource_type = "cpu"
      minimum       = 1
      maximum       = 1
    }
    resource_limits {
      resource_type = "memory"
      minimum       = 1
      maximum       = 1
    }
  }

  # Binary Authorization (requires anthos addon) - a system providing policy control for images deployed to Kubernetes Engine clusters.
  # enable_binary_authorization = true

  enable_shielded_nodes = true

  ip_allocation_policy {
  }
  networking_mode = "VPC_NATIVE"

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = google_compute_subnetwork.private-gke.ip_cidr_range
    }
  }

  pod_security_policy_config {
    enabled = true
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = "172.16.0.64/28"
    master_global_access_config {
      enabled = true
    }
  }

  cluster_telemetry {
    # Supported values: ENABLE, DISABLE, SYSTEM_ONLY
    type = "SYSTEM_ONLY"
  }

  min_master_version = data.google_container_engine_versions.rapid.release_channel_default_version["RAPID"]

  release_channel {
    channel = "RAPID"
  }

  resource_labels = {
    node-owner = local.gke_name
  }

  #TODO define cluster metering in BigQuery
  # resource_usage_export_config {
  #   enable_network_egress_metering = false
  #   enable_resource_consumption_metering = true

  #   bigquery_destination {
  #     dataset_id = "cluster_resource_usage"
  #   }
  # }

  vertical_pod_autoscaling {
    enabled = true
  }

  workload_identity_config {
    identity_namespace = "${var.project}.svc.id.goog"
  }

  enable_intranode_visibility = false

  # TODO chek what the is this...
  # default_snat_status {
  #   disabled = false
  # }
  # TODO finished here  -

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }
}

resource "google_container_node_pool" "gke_nodes" {
  name    = "compute"
  cluster = google_container_cluster.gke.name

  node_config {
    # preemptible  = true
    machine_type = "e2-medium"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    labels = {
      node-owner   = "gke-${google_container_cluster.gke.name}"
      node-purpose = "compute"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }
}


output "gke_master_endpoint" {
  value = google_container_cluster.gke.endpoint
}
