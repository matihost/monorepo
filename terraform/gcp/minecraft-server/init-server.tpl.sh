#!/usr/bin/env bash
set -x

function install_software() {
  apt update
  apt -y install bash-completion vim bind9-dnsutils less mlocate iputils-ping ncat
  # minecraft specific
  apt -y install -y openjdk-16-jre-headless inotify-tools
}

function download_minecraft_data() {
  gsutil cp "gs://${GS_BUCKET}/minecraft-config-template.tar.xz" /tmp
  cd /tmp || exit 6
  tar -Jxvf minecraft-config-template.tar.xz && rm minecraft-config-template.tar.xz
}

function install_minecraft_server() {
  useradd -r -m -U -d /home/minecraft -s /usr/bin/bash minecraft
  mv /tmp/minecraft-server/server /home/minecraft
  chown -R minecraft:minecraft /home/minecraft/server
  mv /tmp/minecraft-server/minecraft.service /etc/systemd/system/minecraft.service
}

function enable_minecraft_server_service() {
  systemctl enable --now minecraft.service
}

# Main
systemctl is-enabled minecraft-server.service &>/dev/null || {
  install_software
  download_minecraft_data
  install_minecraft_server
  enable_minecraft_server_service
}
