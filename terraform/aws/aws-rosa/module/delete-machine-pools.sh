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

max_wait=$((30 * 60))
elapsed=0
interval=10

while [[ "$(rosa list machinepools -c "${CLUSTER_ID}" -o json | jq -r '.[].id' | grep -c "^${MACHINE_POOL_PREFIX}")" -ne 0 ]]; do
  echo "Waiting for ${MACHINE_POOL_PREFIX} to disappear... ($elapsed seconds elapsed)"
  sleep "${interval}"
  elapsed=$((elapsed + interval))
  if ((elapsed >= max_wait)); then
    echo "Timeout reached after 30 minutes... ${MACHINE_POOL_PREFIX} still exist in the cluster "
    exit 1
  fi
done
