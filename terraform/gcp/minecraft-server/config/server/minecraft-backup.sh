#!/usr/bin/env bash

BUCKET=GS_BUCKET
SERVER_NAME=MINECRAFT_SERVER_NAME
PASS=MINECRAFT_PASS
function block_minecraft_from_modyfying_world() {
  #  wait until all files are stored
  # TODO make waiting inotifywait
  say "Attempt to backup the world..." &&
    ./mcrcon -H localhost -P 25575 -w 5 -p "${PASS}" save-all save-off &&
    sleep 5
}

function create_backup() {
  rm -rf backup
  mkdir -p backup
  # shellcheck disable=SC2035
  cp -r world *.json *.properties *.png backup/
  # shellcheck disable=SC2035
  cd backup &&
    tar -cf world-backup.tar world *.json *.properties *.png && cd ..
}

function send_backup_to_gs() {
  gsutil cp -Z backup/world-backup.tar "gs://${1}/${2}/"
}

function unblock_periodic_world_writes() {
  ./mcrcon -H localhost -P 25575 -p "${PASS}" save-on
}

function clean_after_itself() {
  rm -rf backup
}

function say() {
  echo "${1:?Text to say is required}"
  ./mcrcon -H localhost -P 25575 -p "${PASS}" "say ${1:?Text to say is required}"
}

# Main
block_minecraft_from_modyfying_world &&
  create_backup &&
  send_backup_to_gs "${BUCKET}" "${SERVER_NAME}" &&
  unblock_periodic_world_writes
# shellcheck disable=SC2181
[ "$?" -eq 0 ] || {
  clean_after_itself
  say "WARNING: Backup failed. Contact with administrator."
  exit 1
}
clean_after_itself
say "Backup completed."
