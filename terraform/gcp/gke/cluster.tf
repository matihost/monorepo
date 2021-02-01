data "google_container_engine_versions" "rapid" {
  provider = google-beta
  # version differ per region or zonal cluster
  # run: gcloud container get-server-config
  # to see available versions
  location       = local.location
  version_prefix = "1.19."

  project = var.project
}

resource "google_container_cluster" "gke" {
  provider = google-beta

  name        = local.gke_name
  description = "GKE Cluster ${local.gke_name}"
  # When zone, provided cluster is zonal, when region provider cluster is redional.
  # Regional cluster has a charge fee.
  location = local.location

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
      minimum       = 0
      maximum       = 24
    }
    resource_limits {
      resource_type = "memory"
      minimum       = 0
      maximum       = 48
    }
    # whether the cluster autoscaler should optimize for resource utilization (OPTIMIZE_UTILIZATION)
    # or resource availability (BALANCED) when deciding to remove nodes from a cluster
    autoscaling_profile = "OPTIMIZE_UTILIZATION"
    auto_provisioning_defaults {
      oauth_scopes = [
        "https://www.googleapis.com/auth/cloud-platform"
      ]
      service_account = google_service_account.gke-sa.email
    }
  }

  # etcd encryption
  database_encryption {
    state    = "ENCRYPTED"
    key_name = data.google_kms_crypto_key.gke-etcd-enc-key.self_link
  }

  # Binary Authorization (requires anthos addon) - a system providing policy control for images
  # deployed to Kubernetes Engine clusters.
  # enable_binary_authorization = true

  enable_shielded_nodes = true

  # Allocate IPs in our subnetwork
  ip_allocation_policy {
    cluster_secondary_range_name  = google_compute_subnetwork.private-gke.secondary_ip_range.0.range_name
    services_secondary_range_name = google_compute_subnetwork.private-gke.secondary_ip_range.1.range_name
  }
  networking_mode = "VPC_NATIVE"

  # Disable basic authentication and cert-based authentication.
  # Empty fields for username and password are how to "disable" the
  # credentials from being generated.
  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = google_compute_subnetwork.private-gke.ip_cidr_range
    }
    # PublicIP cannot be added as authorized  when enable_private_endpoint is true
    dynamic "cidr_blocks" {
      for_each = var.expose_master_via_external_ip ? [1] : []
      content {
        cidr_block = "${var.external_access_ip}/32"
      }
    }
  }

  pod_security_policy_config {
    enabled = true
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = !var.expose_master_via_external_ip
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

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }

  // Allow plenty of time for each operation to finish (default was 10m)
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }

  depends_on = [
    google_compute_router_nat.nat,
  ]
}

resource "google_container_node_pool" "gke_nodes" {
  name       = "compute"
  location   = local.location
  cluster    = google_container_cluster.gke.name
  node_count = 1

  # Repair any issues but don't auto upgrade node versions
  management {
    auto_repair = true
    # Auto_upgrade cannot be false when release_channel RAPID is set
    auto_upgrade = true
  }

  node_config {
    # preemptible  = true
    # use 4cores and 16 GB ram, e2-medium - 2 cores and 4 GB RAM is too small for all apps running on node
    machine_type = "e2-standard-4"
    # machine_type = "e2-medium"
    # disk_type    = "pd-ssd"
    disk_size_gb = 30

    # since 1.20 usage of docker as container engine is deprecated
    # valid image types: gcloud container get-server-config
    image_type = "UBUNTU_CONTAINERD"

    metadata = {
      // Set metadata on the VM to supply more entropy
      google-compute-enable-virtio-rng = "true"
      // Explicitly remove GCE legacy metadata API endpoint
      disable-legacy-endpoints = "true"
    }

    labels = {
      node-owner = "gke-${google_container_cluster.gke.name}"
      # kubernetes.io/role - cannot be used, because kubernetes.io/ and k8s.io/ prefixes
      # are reserved by Kubernetes Core components and cannot be specified anymore on node
      # use nodeSelector: cloud.google.com/gke-nodepool to select placement on particual node pool
      node-role = "compute"
    }

    # network tags - for firewall handling - as various node pool run using same gcp sa
    # use it to open firewall for NEG from LB
    tags = ["gke-compute"]

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    service_account = google_service_account.gke-sa.email

    // Enable workload identity on this node pool
    workload_metadata_config {
      node_metadata = "GKE_METADATA_SERVER"
    }
  }

  autoscaling {
    min_node_count = 1
    max_node_count = 5
  }
}

output "gke_name" {
  value = google_container_cluster.gke.name
}

output "gke_master_endpoint" {
  value = google_container_cluster.gke.endpoint
}


output "gke_connect_cmd" {
  value = format("gcloud container clusters get-credentials %s --zone %s --internal-ip", google_container_cluster.gke.name, local.zone)
}
