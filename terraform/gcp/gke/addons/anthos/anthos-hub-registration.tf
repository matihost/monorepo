data "google_container_cluster" "cluster" {
  name     = local.gke_name
  location = local.location
}

module "hub" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/fleet-membership"
  version = ">= 30"

  project_id      = var.project
  cluster_name    = data.google_container_cluster.cluster.name
  location        = local.location
  membership_name = "${local.gke_name}-${local.location}"
}
