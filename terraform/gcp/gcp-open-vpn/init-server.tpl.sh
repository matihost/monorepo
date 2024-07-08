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

function download_openvpn_config_template() {
  gsutil cp "gs://${GS_BUCKET}/openvpn-template.tar.xz" /tmp
  cd /tmp || exit 6
  tar -Jxvf openvpn-template.tar.xz && rm openvpn-template.tar.xz
}

function setup_pki() {
  cd /tmp/openvpn/server || exit 6

  # Generate CA key and cert
  openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 \
    -extensions easyrsa_ca -keyout ca.key -out ca.crt \
    -subj "/C=${COUNTRY}/ST=${STATE}/L=${CITY}/O=${ORG}/emailAddress=me@myhost.mydomain" \
    -config openssl.cnf

  # Create server key and cert
  openssl req -new -nodes -config openssl.cnf -extensions server \
    -keyout server.key -out server.csr \
    -subj "/C=${COUNTRY}/ST=${STATE}/O=${ORG}/CN=${CN_SERVER}/emailAddress=me@myhost.mydomain"
  openssl ca -batch -config openssl.cnf -extensions server \
    -out server.crt -in server.csr

  # Normally it should run
  # openssl dhparam -out dh2048.pem 2048
  # but it takes really long...
  cat >dh2048.pem <<EOF
-----BEGIN DH PARAMETERS-----
MIIBCAKCAQEA4kf0aBV747+KHlrIXhj/6uqhHq+5gxHHnwm0sHaZ12PKLqojWJ4k
d7Tv/IKCjBUNuBVZVQ//v1suj+u6mE/qix9QyMLpmT/tlKPb1wYkChFjjFVpMiFv
8H0Rqqv2uD3aJdkkXBd4xKKfULzyl/HCNMRPKbFEaT42Yjli0tOFLGgEe2BGJPNg
96RCCrScHOCcAStOOeCm2l6pINVsf4gupYzl5cgsX1Ua4mvf3LPKo2ivbdgY+4/1
0zpLRbCc7KgPCs2XQHPTcqueCEjS42AdKYJj0ZmabLcm1BSoWXV9ujMxuwnOxL8n
Xuo09rig2uk6ntzF3+lwFdlOVXYc4W5nSwIBAg==
-----END DH PARAMETERS-----
EOF

  openvpn --genkey --secret ta.key

  # Create client key and cert
  openssl req -new -nodes -config openssl.cnf \
    -keyout client.key -out client.csr \
    -subj "/C=${COUNTRY}/ST=${STATE}/O=${ORG}/CN=${CN_CLIENT}/emailAddress=me@myhost.mydomain"
  openssl ca -batch -config openssl.cnf \
    -out client.crt -in client.csr

  cp ca.crt ta.key /tmp/openvpn/client/
  mv client.* /tmp/openvpn/client/
  cp -r /tmp/openvpn/* /etc/openvpn/
  rm -rf /tmp/openvpn
}

function setup_nat() {
  sysctl -w net.ipv4.ip_forward=1
  echo 'net.ipv4.ip_forward=1' >/etc/sysctl.d/30-openvpn-forward.conf

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

function configure_client() {
  echo "remote $(curl -sH "Metadata-Flavor: Google" http://metadata/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip) 1194" >>/etc/openvpn/client/client.conf
  cd /etc/openvpn/client || exit 6
  tar -Jcvf /tmp/openvpn-client.tar.xz ./*
  gsutil cp /tmp/openvpn-client.tar.xz "gs://${GS_BUCKET}/"
  rm /tmp/openvpn-client.tar.xz
}

function enable_openvpn() {
  systemctl enable --now openvpn-server@server.service
}

# Main
systemctl is-enabled openvpn-server@server.service &>/dev/null || {
  install_software
  download_openvpn_config_template
  setup_pki
  setup_nat
  configure_client
  enable_openvpn
}
