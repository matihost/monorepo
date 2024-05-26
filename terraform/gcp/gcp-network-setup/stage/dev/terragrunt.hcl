include "root" {
  path = find_in_parent_folders()
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module")}///"
}

inputs = {
  env                    = "dev"
  dns_suffix             = "gcp.testing."
  asn                    = 64514
  psa_peering_cidr_range = "10.9.0.0/16"
  region                 = "us-central1"
  zone                   = "us-central1-a"
  regions = {
    "us-central1" = {
      ip_cidr_range         = "10.10.0.0/16",
      l7lb_proxy_cidr_range = "10.13.0.0/24",
      secondary_ranges = [
        # max pods: 32,766
        { range_name = "pod-range-0",
        ip_cidr_range = "100.64.0.0/17" },
        { range_name = "pod-range-1",
        ip_cidr_range = "100.66.0.0/17" },
        # max svcs: 4,094
        { range_name = "svc-range-0",
        ip_cidr_range = "100.96.0.0/20" },
        { range_name = "svc-range-1",
        ip_cidr_range = "100.96.16.0/20" },
      ]
    },
    "us-east1" = {
      ip_cidr_range         = "10.14.0.0/16",
      l7lb_proxy_cidr_range = "10.13.1.0/24",
      secondary_ranges = [
        { range_name = "pod-range-0",
        ip_cidr_range = "100.68.0.0/17" },
        { range_name = "pod-range-1",
        ip_cidr_range = "100.70.0.0/17" },
        { range_name = "svc-range-0",
        ip_cidr_range = "100.96.32.0/20" },
        { range_name = "svc-range-1",
        ip_cidr_range = "100.96.48.0/20" },
      ]
    },
    "europe-central2" = {
      ip_cidr_range         = "10.15.0.0/16",
      l7lb_proxy_cidr_range = "10.13.2.0/24",
      secondary_ranges = [
        { range_name = "pod-range-0",
        ip_cidr_range = "100.72.0.0/17" },
        { range_name = "pod-range-1",
        ip_cidr_range = "100.74.0.0/17" },
        { range_name = "svc-range-0",
        ip_cidr_range = "100.96.64.0/20" },
        { range_name = "svc-range-1",
        ip_cidr_range = "100.96.80.0/20" },
      ]
    },
  }
}
