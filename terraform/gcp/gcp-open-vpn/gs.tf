resource "random_id" "vpn-random" {
  byte_length = 4
}

resource "google_storage_bucket" "vpn-data" {
  name          = "vpn-${random_id.vpn-random.hex}"
  force_destroy = true
  # GCP free tier GS is free only with regional class in some US regions
  location      = var.region
  storage_class = "REGIONAL"
}


resource "null_resource" "openvpn-template" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "pwd && mkdir -p target && tar -Jcvf target/openvpn-template.tar.xz openvpn"
  }
}

resource "google_storage_bucket_object" "openvpn-template" {
  name   = "openvpn-template.tar.xz"
  source = "target/openvpn-template.tar.xz"
  bucket = google_storage_bucket.vpn-data.name

  depends_on = [null_resource.openvpn-template]
}


output "openvpn_bucket" {
  value = google_storage_bucket.vpn-data.name
}
