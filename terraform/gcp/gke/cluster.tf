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
  network    = data.google_compute_network.private-gke.name
  subnetwork = data.google_compute_subnetwork.private-gke.name

  project = var.project

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  # TODO consider parametrizing
  # enable_tpu = false

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
    kalm_config {
      enabled = true
    }
    config_connector_config {
      enabled = true
    }
  }

  network_policy {
    enabled = true
    # provider = "CALICO"
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
  dynamic "database_encryption" {
    for_each = var.encrypt_etcd ? [1] : []
    content {
      state    = "ENCRYPTED"
      key_name = data.google_kms_crypto_key.gke-etcd-enc-key[0].self_link
    }
  }

  # Binary Authorization (requires anthos addon) - a system providing policy control for images
  # deployed to Kubernetes Engine clusters.
  # enable_binary_authorization = true

  enable_shielded_nodes = true

  # Allocate IPs in our subnetwork
  # It is possible to use non-RFC1918 ip for pods and svc but it has implications:
  # https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips#enable_reserved_ip_ranges
  ip_allocation_policy {
    cluster_secondary_range_name  = "pod-range-${var.secondary_ip_range_number}"
    services_secondary_range_name = "svc-range-${var.secondary_ip_range_number}"
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
      cidr_block   = data.google_compute_subnetwork.private-gke.ip_cidr_range
      display_name = "from GKE nodes subnetwork"
    }
    cidr_blocks {
      cidr_block   = "10.0.0.0/8"
      display_name = "from entire VPC network"
    }
    # PublicIP cannot be added as authorized  when enable_private_endpoint is true
    dynamic "cidr_blocks" {
      for_each = var.external_access_cidrs
      iterator = cidr
      content {
        cidr_block = cidr.value
      }
    }
  }

  pod_security_policy_config {
    enabled = var.enable_pod_security_policy
  }

  # Ability to use G Suite Groups in GKE RBACs
  #
  # authenticator_groups_config {
  #   security_group = "security-groups@DOM.com"
  # }
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = !var.expose_master_via_external_ip
    master_ipv4_cidr_block  = var.master_cidr
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

  vertical_pod_autoscaling {
    enabled = true
  }

  workload_identity_config {
    identity_namespace = "${var.project}.svc.id.goog"
  }

  # Whether Intra-node visibility is enabled for this cluster. This makes same node pod to pod traffic visible for VPC network.
  enable_intranode_visibility = false

  # This option is required if you privately use non-RFC 1918/public IP addresses for your Pods or Services.
  # Disabling SNAT is required so that responses can be routed to the Pod that originated the traffic.
  # Using public ips to pods using as private may cause problems with CloudNAT:
  # https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips#internal_ip_addresses
  #
  # default_snat_status {
  #   disabled = true
  # }

  dynamic "resource_usage_export_config" {
    for_each = var.bigquery_metering ? [1] : []
    content {
      # this requires prerequisite: https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-usage-metering#enable-network-egress-metering
      enable_network_egress_metering       = false
      enable_resource_consumption_metering = true

      bigquery_destination {
        dataset_id = "${replace(var.region, "-", "_")}_dataset"
      }
    }
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }

  lifecycle {
    ignore_changes = [initial_node_count]
  }

  // Allow plenty of time for each operation to finish (default was 10m)
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }

  # aka https://www.terraform.io/docs/cloud/api/notification-configurations.html
  # notification_config {
  #   pubsub {
  #     enabled = true
  #     topic   = notification_topic
  #   }
  # }
}

resource "random_id" "gke_node_pool_id" {
  byte_length = 2
}

resource "google_container_node_pool" "gke_nodes" {
  name       = "compute-${random_id.gke_node_pool_id.hex}"
  location   = local.location
  cluster    = google_container_cluster.gke.name
  node_count = 1

  max_pods_per_node = 110

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

    # GCP Free tier has only: pd-standard - which is default disk type
    # increase size and switch type to pd-balanced or pd-ssd for better performance
    # https://cloud.google.com/compute/disks-image-pricing - for pricing
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

    # requires image_type = COS_CONTAINERD as well
    # sandbox_config {
    #   sandbox_type= "gvisor"
    # }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
  }

  autoscaling {
    min_node_count = 1
    max_node_count = 5
  }

  lifecycle {
    ignore_changes = [initial_node_count]
    # so that first new node pool is created (with random name)
    # before node pool is removed so that pods from destroyed node pool has somewhere to migrate
    create_before_destroy = true
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
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
