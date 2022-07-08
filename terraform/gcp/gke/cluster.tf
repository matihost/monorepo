data "google_container_engine_versions" "versions" {
  provider = google-beta
  # version differ per region or zonal cluster
  # run: gcloud container get-server-config
  # to see available versions
  location       = local.location
  version_prefix = "1.23."

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

    # when https://cloud.google.com/kubernetes-engine/docs/how-to/dataplane-v2 enabled
    # network policy is enabled by default and attempt to set it ends with error
    # network_policy_config {
    #   disabled = false
    # }

    gcp_filestore_csi_driver_config {
      enabled = true
    }

    dns_cache_config {
      enabled = true
    }
    gce_persistent_disk_csi_driver_config {
      enabled = true
    }

    # Disabled Application Manager:
    # https://cloud.google.com/kubernetes-engine/docs/how-to/add-on/application-delivery
    kalm_config {
      enabled = false
    }
    config_connector_config {
      enabled = true
    }
  }

  # when https://cloud.google.com/kubernetes-engine/docs/how-to/dataplane-v2 enabled
  # network policy is enabled by default and attempt to set it ends with error
  # network_policy {
  #   enabled = true
  #   # provider = "CALICO"
  # }


  cluster_autoscaling {
    enabled = var.enable_auto_nodepools

    dynamic "resource_limits" {
      for_each = var.enable_auto_nodepools ? [1] : []
      content {
        resource_type = "cpu"
        minimum       = 0
        maximum       = 24
      }
    }

    dynamic "resource_limits" {
      for_each = var.enable_auto_nodepools ? [1] : []
      content {
        resource_type = "memory"
        minimum       = 0
        maximum       = 48
      }
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
      key_name = data.google_kms_crypto_key.gke-etcd-enc-key[0].id
    }
  }

  # Binary Authorization (requires Anthos subscription or standalone
  # a system providing policy control for images
  # deployed to Kubernetes Engine clusters.
  # enable_binary_authorization = true

  enable_shielded_nodes = true

  # GKE standalone mode
  #enable_autopilot = false

  # Allocate IPs in our subnetwork
  # It is possible to use non-RFC1918 ip for pods and svc but it has implications:
  # https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips#enable_reserved_ip_ranges
  ip_allocation_policy {
    cluster_secondary_range_name  = "pod-range-${var.secondary_ip_range_number}"
    services_secondary_range_name = "svc-range-${var.secondary_ip_range_number}"
  }
  networking_mode = "VPC_NATIVE"

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  master_auth {
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

  # Cannot specify logging_config or monitoring_config together with cluster_telemetry
  # cluster_telemetry {
  #   # Supported values: ENABLE, DISABLE, SYSTEM_ONLY
  #   type = "SYSTEM_ONLY"
  # }

  min_master_version = data.google_container_engine_versions.versions.release_channel_default_version["RAPID"]

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }
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
    workload_pool = "${var.project}.svc.id.goog"
  }

  # Whether Intra-node visibility is enabled for this cluster.
  # This makes same node pod to pod traffic visible for VPC network.
  enable_intranode_visibility = false

  # internal-load-balancing subsetting
  # uses GKE controlled NEGs for each service using a subset of the GKE nodes as members
  enable_l4_ilb_subsetting = true

  # TODO can be enabled when subnetwork has same property enabled
  # controls whether and how the pods can communicate with Google Services through gRPC over IPv6.
  # private_ipv6_google_access = "PRIVATE_IPV6_GOOGLE_ACCESS_BIDIRECTIONAL"

  # The desired datapath provider for this cluster. By default, uses the IPTables-based kube-proxy implementation.
  # ADVANCED_DATAPATH is dataplane v2 implementation: https://cloud.google.com/kubernetes-engine/docs/how-to/dataplane-v2
  # https://cloud.google.com/kubernetes-engine/docs/reference/rest/v1beta1/projects.locations.clusters#datapathprovider
  datapath_provider = "ADVANCED_DATAPATH"

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

  # Confidential VM is only available on N2D instances of Compute Engine.
  # Confidential GKE Nodes can be used with Container-Optimized OS (cos_containerd).
  confidential_nodes {
    enabled = false
  }

  depends_on = [
    google_project_service.gke-apis
  ]
}

resource "random_id" "gke_node_pool_id" {
  byte_length = 2
  keepers = {
    machine_type = "e2-standard-4"
    disk_size_gb = 30
    disk_type    = "pd-standard"
  }
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
    # machine_type = "e2-standard-4"
    machine_type = random_id.gke_node_pool_id.keepers.machine_type

    # GCP Free tier has only: pd-standard - which is default disk type
    # increase size and switch type to pd-balanced or pd-ssd for better performance
    # https://cloud.google.com/compute/disks-image-pricing - for pricing
    # disk_type    = "pd-ssd"
    disk_type    = random_id.gke_node_pool_id.keepers.disk_type
    disk_size_gb = random_id.gke_node_pool_id.keepers.disk_size_gb

    # Parameters for the ephemeral storage filesystem.
    # # If unspecified, ephemeral storage is backed by the boot disk
    # ephemeral_storage_config {
    #   # Number of local SSDs to use to back ephemeral storage.
    #   # Uses NVMe interfaces. Each local SSD is 375 GB in size.
    #   # If zero, it means to disable using local SSDs as ephemeral storage.
    #   local_ssd_count = 2
    # }

    # GKE usually downloads the entire container image onto each node and uses it as the root filesystem for your workloads.
    # With Image streaming, GKE uses a remote filesystem as the root filesystem for any containers that use eligible container images.
    # GKE streams image data from the remote filesystem as needed by your workloads.
    #
    # requires image_type = COS_CONTAINERD and >= 16 GiB memory for node
    gcfs_config {
      enabled = true
    }

    # since 1.20 usage of docker as container engine is deprecated
    # valid image types: gcloud container get-server-config
    image_type = "COS_CONTAINERD"

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
      mode = "GKE_METADATA"
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
    ignore_changes = [initial_node_count, node_count]
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
