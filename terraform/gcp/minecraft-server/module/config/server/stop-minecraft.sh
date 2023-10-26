#!/usr/bin/env bash

set -x

MAINPID=${1:?Main pid is required}

SERVER_NAME=MINECRAFT_SERVER_NAME
PASS=MINECRAFT_PASS

function say() {
  ./mcrcon -H localhost -P 25575 -p "${PASS}" "say ${1:?Text to say is required}"
}

function shutdown_minecraft_server() {
  kill "${MAINPID}"
  # TODO maybe stop gracefullier
  #./mcrcon -H 127.0.0.1 -P 25575 -p alamakota stop
  pkill -f server.jar
}

# Main
say "WARNING: About to stop ${SERVER_NAME} server!"
# when minecraft proces is alive, proactively do backup
pgrep -f server.jar &>/dev/null && {
  ./minecraft-backup.sh
}

say "WARNING: Stopping ${SERVER_NAME} server now! Bye!"
shutdown_minecraft_server
