#!/usr/bin/env bash

set -x

MAINPID=${1:?Main pid is required}

function shutdown_minecraft_server() {
  kill "${MAINPID}"
  # TODO maybe stop gracefullier
  #./mcrcon -H 127.0.0.1 -P 25575 -p alamakota stop
  pkill -f server.jar
}

# Main

# when minecraft proces is alive, proactively do backup
pgrep -f server.jar &>/dev/null && {
  ./minecraft-backup.sh
}

shutdown_minecraft_server
