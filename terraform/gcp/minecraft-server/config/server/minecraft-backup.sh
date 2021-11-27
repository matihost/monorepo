#!/usr/bin/env bash

BUCKET=GS_BUCKET
SERVER_NAME=MINECRAFT_SERVER_NAME
PASS=MINECRAFT_PASS
function block_minecraft_from_modyfying_world() {
  #  wait until all files are stored
  # TODO make waiting inotifywait
  ./mcrcon -H localhost -P 25575 -p "${PASS}" "say Attempt to backup the world..." &&
    ./mcrcon -H localhost -P 25575 -w 5 -p "${PASS}" save-all save-off &&
    sleep 20
}

function create_backup() {
  # shellcheck disable=SC2035
  mkdir -p backup &&
    tar -Jcvf backup/world-backup.tar.xz world *.json *.properties *.png
}

function send_backup_to_gs() {
  gsutil cp backup/world-backup.tar.xz "gs://${1}/${2}/"
}

function unblock_periodic_world_writes() {
  ./mcrcon -H localhost -P 25575 -p "${PASS}" save-on "say Backup completed"
}

# Main
block_minecraft_from_modyfying_world &&
  create_backup &&
  send_backup_to_gs "${BUCKET}" "${SERVER_NAME}" &&
  unblock_periodic_world_writes
# shellcheck disable=SC2181
[ "$?" -eq 0 ] || {
  echo "Backup failed"
  exit 1
}
