locals {
  required-apis = ["meshtelemetry"]
}

resource "google_project_service" "required-api" {
  count              = length(local.required-apis)
  service            = "${local.required-apis[count.index]}.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_firewall" "gke-accept-istio-webhook" {
  name          = "${local.gke_name}-accept-istio-webhook"
  description   = "Allow traffic to GKE nodes for istio webhook from GKE Master Nodes"
  network       = data.google_container_cluster.gke.network
  direction     = "INGRESS"
  project       = var.project
  source_ranges = [data.google_container_cluster.gke.private_cluster_config[0].master_ipv4_cidr_block]

  allow {
    protocol = "tcp"
    ports    = ["15017"]
  }

  target_service_accounts = [local.gke_nodes_sa]
}


resource "random_id" "internal_pool_random" {
  byte_length = 2
  keepers = {
    machine_type = "n1-standard-1"
    disk_size_gb = 20
    disk_type    = "pd-standard"
  }
}

resource "google_container_node_pool" "gke_internal_ingress_nodes" {
  count = var.enable_internal_ingress_node_pool ? 1 : 0

  name       = "internal-ingress--${random_id.internal_pool_random.hex}"
  location   = local.location
  cluster    = data.google_container_cluster.gke.name
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
    machine_type = random_id.internal_pool_random.keepers.machine_type

    # GCP Free tier has only: pd-standard - which is default disk type
    # increase size and switch type to pd-balanced or pd-ssd for better performance
    # https://cloud.google.com/compute/disks-image-pricing - for pricing
    # disk_type    = "pd-ssd"
    disk_type    = random_id.internal_pool_random.keepers.disk_type
    disk_size_gb = random_id.internal_pool_random.keepers.disk_size_gb

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
      node-owner = "gke-${data.google_container_cluster.gke.name}"
      # kubernetes.io/role - cannot be used, because kubernetes.io/ and k8s.io/ prefixes
      # are reserved by Kubernetes Core components and cannot be specified anymore on node
      # use nodeSelector: cloud.google.com/gke-nodepool to select placement on particual node pool
      node-role = "internal-ingress"
    }

    taint = [{
      effect = "NO_SCHEDULE"
      key    = "ingress-type"
      value  = "internal"
    }]

    # network tags - for firewall handling - as various node pool run using same gcp sa
    # use it to open firewall for NEG from LB
    tags = ["gke-compute"]

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    service_account = local.gke_nodes_sa

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
    max_node_count = 6
  }

  lifecycle {
    ignore_changes = [initial_node_count, node_config[0].taint]
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

resource "random_id" "external_pool_random" {
  byte_length = 2
  keepers = {
    machine_type = "n1-standard-1"
    disk_size_gb = 20
    disk_type    = "pd-standard"
  }
}

resource "google_container_node_pool" "gke_external_ingress_nodes" {
  count = var.enable_external_ingress_node_pool ? 1 : 0

  name       = "external-ingress--${random_id.external_pool_random.hex}"
  location   = local.location
  cluster    = data.google_container_cluster.gke.name
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
    # there is a quota of max 8 CPU core per region on Free Tier Account
    machine_type = random_id.external_pool_random.keepers.machine_type

    # GCP Free tier has only: pd-standard - which is default disk type
    # increase size and switch type to pd-balanced or pd-ssd for better performance
    # https://cloud.google.com/compute/disks-image-pricing - for pricing
    # disk_type    = "pd-ssd"
    disk_type    = random_id.external_pool_random.keepers.disk_type
    disk_size_gb = random_id.external_pool_random.keepers.disk_size_gb

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
      node-owner = "gke-${data.google_container_cluster.gke.name}"
      node-role  = "external-ingress"
    }

    taint = [{
      effect = "NO_SCHEDULE"
      key    = "ingress-type"
      value  = "external"
    }]

    # network tags - for firewall handling - as various node pool run using same gcp sa
    # use it to open firewall for NEG from LB
    tags = ["gke-compute"]

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    service_account = local.gke_nodes_sa

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
    max_node_count = 6
  }

  lifecycle {
    ignore_changes = [initial_node_count, node_config[0].taint]
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
