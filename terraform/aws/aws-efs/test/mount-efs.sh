#!/usr/bin/env bash
EFS_FILESYSTEM_ID="${1:?EFS_FILESYSTEM_ID is required}"

REGION="${2:-'us-east-1'}"
MOUNT_DNS="${EFS_FILESYSTEM_ID}.efs.${REGION}.amazonaws.com"

set -e

function ensure_efs_client_is_installed() {
  [ "$(apt list --installed 2>/dev/null | grep -c amazon-efs-utils)" -eq 1 ] || {
    cd /tmp || return
    sudo apt-get -y install git binutils rustc cargo pkg-config libssl-dev gettext
    git clone https://github.com/aws/efs-utils
    (
      cd efs-utils || return
      ./build-deb.sh
      sudo apt-get -y install ./build/amazon-efs-utils*deb
    )
    rm -rf efs-utils
  }
}

function mount_efs() {
  sudo mount -t efs "${MOUNT_DNS}:/" /mnt/efs
}

ensure_efs_client_is_installed
mount_efs
