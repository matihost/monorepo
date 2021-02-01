data "google_container_cluster" "cluster" {
  name     = local.gke_name
  location = local.location
}

module "hub" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/hub"

  project_id              = var.project
  cluster_name            = local.gke_name
  location                = local.location
  cluster_endpoint        = data.google_container_cluster.cluster.endpoint
  gke_hub_membership_name = "${local.gke_name}-${local.location}"
  gke_hub_sa_name         = "hub-sa"
}
