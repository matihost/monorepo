#!/usr/bin/env bash

BUCKET=GS_BUCKET
SERVER_NAME=MINECRAFT_SERVER_NAME
PASS=MINECRAFT_PASS
OP_USER=MINECRAFT_SERVER_OP_USER

GS_BACKUP_OBJECT="gs://${BUCKET}/${SERVER_NAME}/world-backup.tar.xz"

FOREGROUND=${1:-background}

function download_minecraft_backup() {
  mkdir -p backup
  # shellcheck disable=SC2035
  gsutil cp "${GS_BACKUP_OBJECT}" backup/ && {
    cp backup/world-backup.tar.xz . &&
      rm -rf world *.properties *.json &&
      tar -Jxvf world-backup.tar.xz &&
      rm world-backup.tar.xz
  }
}

function check_for_minecraft_server() {
  timeout="5 minute"
  deadline=$(date -ud "${timeout}" +%s)
  while [ -z "$(./mcrcon -H 127.0.0.1 -P 25575 -p "${PASS}" 'time query gametime' 2>/dev/null | xargs)" ] && [[ $(date -u +%s) -le ${deadline} ]]; do
    sleep 2
    echo "Awaiting for Minecraft ${SERVER_NAME} server to be alive"
  done
  if [ -z "$(./mcrcon -H 127.0.0.1 -P 25575 -p "${PASS}" 'time query gametime' 2>/dev/null | xargs)" ]; then
    echo "Minecraft ${SERVER_NAME} server seems not alive"
    exit 1
  fi
}

function init_op_user() {
  ./mcrcon -H 127.0.0.1 -P 25575 -p "${PASS}" "op ${OP_USER}"
}

function run_minecraft_server() {
  /usr/bin/java -Xms3072M -Xmx3072M -jar server.jar nogui &
  check_for_minecraft_server
  init_op_user
}

# Main

# when nothing initialized attempt to download backup if present
[ -d "world" ] || {
  download_minecraft_backup
}
run_minecraft_server

[ "${FOREGROUND}" = "foreground" ] && {
  # fg does not work under systemd, wait for Minecraft server to shutdown
  wait -f "$(pgrep -f server.jar)"
}
