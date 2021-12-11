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
  # TODO remove -Dlog4j2.formatMsgNoLookups=true (workaround for CVE-2021-44228) when Minecraft bumb log4j 2.x to 2.15.x
  /usr/bin/java -XX:+UnlockExperimentalVMOptions \
    -Xms2880M -Xmx2880M -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 \
    -XshowSettings:* -XX:+PrintFlagsFinal -XX:NativeMemoryTracking=summary -Xlog:async -Xlog:gc*=debug,gc+ergo*=trace,gc+age*=trace,safepoint*:file=/tmp/minecraft.gc.log:level,tags,utctime,uptime,pid:filecount=5,filesize=100m \
    -XX:OnOutOfMemoryError='kill -9 %p' -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/tmp \
    -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:+UseNUMA -XX:+PreserveFramePointer \
    -Dlog4j2.formatMsgNoLookups=true \
    -jar server.jar nogui &
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
