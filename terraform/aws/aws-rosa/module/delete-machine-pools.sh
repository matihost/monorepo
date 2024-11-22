#!/usr/bin/env bash

CLUSTER_ID="${1:?CLUSTER_ID is required}"
MACHINE_POOL_PREFIX="${2:?MACHINE_POOL_PREFIX is required}"

set -e
# set -x

# shellcheck disable=SC2034
DIRNAME="$(dirname "$0")"

MACHINE_POOLS="$(rosa list machinepools -c "${CLUSTER_ID}" -o json | jq -r '.[].id')"

for pool in $MACHINE_POOLS; do
  # Check if the word starts with "worker"
  if [[ "${pool}" == ${MACHINE_POOL_PREFIX}* ]]; then
    rosa delete machinepool -c "${CLUSTER_ID}" "${pool}" -y
  fi
done
