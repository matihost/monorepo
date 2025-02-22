locals {
  current_ip = "${run_cmd("--terragrunt-quiet", "dig", "+short", "myip.opendns.com", "@resolver1.opendns.com")}"
  pub_ssh    = try(file("~/.ssh/id_rsa.cloud.vm.pub"), get_env("SSH_PUB", ""))
  ssh_key    = try(file("~/.ssh/id_rsa.cloud.vm"), get_env("SSH_PRIV", ""))

  env       = "dev"
  country   = "PL"
  state     = "XX"
  city      = "YYY"
  org       = local.env
  ca_email  = "me@me.me"
  server_cn = "${local.env}.vpn.server"
  client_cn = "${local.env}.vpn.client"

  ca_crt = try(file("~/.tls/openvpn/${local.org}/ca.crt"), try(get_env("VPN_CA_CRT"), run_cmd("--terragrunt-quiet", find_in_parent_folders("create-ca-crt.sh"), local.org, local.country, local.state, local.city, local.ca_email)))
  ca_key = try(file("~/.tls/openvpn/${local.org}/ca.key"), try(get_env("VPN_CA_KEY"), run_cmd("--terragrunt-quiet", find_in_parent_folders("create-ca-crt.sh"), local.org, local.country, local.state, local.city, local.ca_email, "key")))


  ta_key = try(file("~/.tls/openvpn/${local.org}/ta.key"), try(get_env("VPN_TA_KEY"), run_cmd("--terragrunt-quiet", find_in_parent_folders("create-ta-key.sh"), local.org)))
  dh     = try(file("~/.tls/openvpn/${local.org}/dh2048.pem"), try(get_env("VPN_DH"), run_cmd("--terragrunt-quiet", find_in_parent_folders("create-dh.sh"), local.org)))

  server_crt = try(file("~/.tls/openvpn/${local.org}/server.crt"), try(get_env("VPN_SERVER_CRT"), run_cmd("--terragrunt-quiet", find_in_parent_folders("create-server-crt.sh"), local.org, local.server_cn, local.country, local.state, local.ca_email)))
  server_key = try(file("~/.tls/openvpn/${local.org}/server.key"), try(get_env("VPN_SERVER_KEY"), run_cmd("--terragrunt-quiet", find_in_parent_folders("create-server-crt.sh"), local.org, local.server_cn, local.country, local.state, local.ca_email, "key")))

  client_crt = try(file("~/.tls/openvpn/${local.org}/client.crt"), try(get_env("VPN_CLIENT_CRT"), run_cmd("--terragrunt-quiet", find_in_parent_folders("create-client-crt.sh"), local.org, local.client_cn, local.country, local.state, local.ca_email)))
  client_key = try(file("~/.tls/openvpn/${local.org}/client.key"), try(get_env("VPN_CLIENT_KEY"), run_cmd("--terragrunt-quiet", find_in_parent_folders("create-client-crt.sh"), local.org, local.client_cn, local.country, local.state, local.ca_email, "key")))
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module")}///"
}

inputs = {
  env    = local.env
  region = "us-central1"
  zone   = "us-central1-a"

  ssh_pub_key = local.pub_ssh
  ssh_key     = local.ssh_key

  ca_crt     = local.ca_crt
  ca_key     = local.ca_key
  server_crt = local.server_crt
  server_key = local.server_key
  client_crt = local.client_crt
  client_key = local.client_key
  ta_key     = local.ta_key
  dh         = local.dh

  onpremise_dns_zone_forward = {
    zone   = "matihost"
    dns_ip = "10.8.0.2"
  }
}
