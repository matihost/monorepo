#!/usr/bin/env bash
set -x

function install_software() {
  apt update
  apt -y install bash-completion vim bind9-dnsutils less mlocate iputils-ping ncat
  # install OpsAgent (it reserves 8888 and 2020 ports)
  curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
  bash add-google-cloud-ops-agent-repo.sh --also-install
  # minecraft specific
  apt -y install -y openjdk-17-jre-headless inotify-tools
}

function download_minecraft_data() {
  gsutil cp "gs://${GS_BUCKET}/${MINECRAFT_SERVER_NAME}/minecraft-config-template.tar.xz" /tmp
  cd /tmp || exit 6
  tar -Jxvf minecraft-config-template.tar.xz && rm minecraft-config-template.tar.xz
}

function install_minecraft_server() {
  useradd -r -m -U -d /home/minecraft -s /usr/bin/bash minecraft
  mv /tmp/minecraft-server/server /home/minecraft
  chown -R minecraft:minecraft /home/minecraft/server
  mv /tmp/minecraft-server/*.{service,timer} /etc/systemd/system/
}

function enable_minecraft_server_service() {
  systemctl enable --now minecraft.service
  systemctl enable --now minecraft-backup.timer
}

# Main
systemctl is-enabled minecraft-server.service &>/dev/null || {
  install_software
  download_minecraft_data
  install_minecraft_server
  enable_minecraft_server_service
}
