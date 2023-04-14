# Private Service Access
#
# VPC peering to allow managed services in Google VPC like Apigee, CloudSQL etc.
# to be accessible from VPC via internal IP, w/o need to use external ip
# https://cloud.google.com/vpc/docs/configure-private-services-access#creating-connection

# # If you create the allocation yourself instead of having Google do it (such as through Cloud SQL),
# you can use the same naming convention to signal to other users or Google services that an allocation for Google already exists.
# When a Google service allocates a range on your behalf,
# the service uses the following format to name the allocation: google-managed-services-[your network name].
# If this allocation exists, Google services use the existing one instead of creating another one.

resource "google_compute_global_address" "psa-peering-range" {
  name          = "google-managed-services-${google_compute_network.private.name}"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.private.id
  address       = "10.9.0.0"
}



# TODO per Notes:
# Don't reuse the same allocated range for multiple service producers.
# Although it's possible, doing so can lead to IP address overlap.
# Each service producer has visibility only into their network and can't know which IP addresses other service producers are using.
# so
# is servicenetworking.googleapis.com a service producer for all Google managed services?
# aka can we have only one VPC google-managed-services-vpcname range for all Google Managed Service types?

# TODO enable exporting custom routes update on servicenetworking-googleapis-com perring
# to achieve https://cloud.google.com/vpc/docs/configure-private-services-access#on-prem
resource "google_service_networking_connection" "servicenetworking-vpc-connection" {
  network                 = google_compute_network.private.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.psa-peering-range.name]

  depends_on = [
    google_project_service.apis
  ]
}
