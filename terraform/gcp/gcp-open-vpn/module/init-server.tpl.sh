#!/usr/bin/env bash
set -x

function install_software() {
  apt update
  apt -y install bash-completion vim bind9-dnsutils less plocate iputils-ping ncat
  apt -y install -y openvpn openssl ca-certificates firewalld

  # install OpsAgent (it reserves 8888 and 2020 ports)
  curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
  bash add-google-cloud-ops-agent-repo.sh --also-install
}

function setup_pki() {
  cd /etc/openvpn/server || exit 6

  [ -e server.conf ] || {
    curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/server-conf 2>/dev/null >server.conf
  }

  [ -e ca.crt ] || {
    gcloud secrets versions access latest --secret="${PREFIX}-ca-crt" --out-file=ca.crt
    gcloud secrets versions access latest --secret="${PREFIX}-ca-key" --out-file=ca.key
    chmod 600 ca.key

    # or
    # Generate CA key and cert
    # openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 \
    # -extensions easyrsa_ca -keyout ca.key -out ca.crt \
    # -subj "/C=$${COUNTRY}/ST=$${STATE}/L=$${CITY}/O=$${ORG}/emailAddress=me@myhost.mydomain" \
    # -config openssl.cnf
  }

  [ -e server.crt ] || {
    gcloud secrets versions access latest --secret="${PREFIX}-server-crt" --out-file=server.crt
    gcloud secrets versions access latest --secret="${PREFIX}-server-key" --out-file=server.key
    chmod 600 server.key

    # or
    # Create server key and cert
    # openssl req -new -nodes -config openssl.cnf -extensions server \
    #   -keyout server.key -out server.csr \
    #   -subj "/C=$${COUNTRY}/ST=$${STATE}/O=$${ORG}/CN=$${CN_SERVER}/emailAddress=me@myhost.mydomain"
    # openssl ca -batch -config openssl.cnf -extensions server \
    #   -out server.crt -in server.csr
  }

  [ -e dh2048.pem ] || {
    gcloud secrets versions access latest --secret="${PREFIX}-dh" --out-file=dh2048.pem

    # or
    # openssl dhparam -out dh2048.pem 2048
  }

  [ -e ta.key ] || {
    gcloud secrets versions access latest --secret="${PREFIX}-ta-key" --out-file=ta.key

    # or
    # openvpn --genkey --secret ta.key
  }

  [ -e client.crt ] || {
    gcloud secrets versions access latest --secret="${PREFIX}-client-crt" --out-file=client.crt
    gcloud secrets versions access latest --secret="${PREFIX}-client-key" --out-file=client.key
    chmod 600 client.key

    # or
    # Create client key and cert
    # openssl req -new -nodes -config openssl.cnf \
    #   -keyout client.key -out client.csr \
    #   -subj "/C=$${COUNTRY}/ST=$${STATE}/O=$${ORG}/CN=$${CN_CLIENT}/emailAddress=me@myhost.mydomain"
    # openssl ca -batch -config openssl.cnf \
    #   -out client.crt -in client.csr
  }
}

function setup_nat() {
  sysctl -w net.ipv4.ip_forward=1
  # GCP includes a file
  # /etc/sysctl.d/60-gce-network-security.conf:net.ipv4.ip_forward
  # So sysctl rule has to be a file with bigger number...
  echo 'net.ipv4.ip_forward=1' >/etc/sysctl.d/98-openvpn-forward.conf

  # shellcheck disable=SC2034
  port="1194"
  # shellcheck disable=SC2034
  protocol="udp"
  # shellcheck disable=SC2034
  ip="$(curl -H "Metadata-Flavor: Google" http://metadata/computeMetadata/v1/instance/network-interfaces/0/ip 2>/dev/null)"
  # shellcheck disable=SC2140
  firewall-cmd --add-port="$${port}"/"$${protocol}"
  firewall-cmd --zone=trusted --add-source=10.8.0.0/24
  firewall-cmd --direct --add-rule ipv4 nat POSTROUTING 0 -s 10.8.0.0/24 ! -d 10.8.0.0/24 -j SNAT --to "$${ip}"
  firewall-cmd --runtime-to-permanent
}

function enable_openvpn() {
  systemctl enable --now openvpn-server@server.service
}

# Main
systemctl is-enabled openvpn-server@server.service &>/dev/null || {
  install_software
  setup_pki
  setup_nat
  enable_openvpn
}
