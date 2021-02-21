#!/usr/bin/env bash
set -e
set -x
GS_BUCKET="$(terraform output openvpn_bucket | sed -E "s/\"//g")"

mkdir -p target/client && cd target/client
gsutil cp "gs://${GS_BUCKET}/openvpn-client.tar.xz" .
tar -Jxvf openvpn-client.tar.xz
rm openvpn-client.tar.xz

echo "OpenVPN client will start 'tun' interface and connect to VPN. To stop press Ctrl + C"
sudo openvpn client.conf
