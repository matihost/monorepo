#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

LOCATION=westeurope

STATE_RG="$("${SCRIPT_DIR}"/get_state_rg_name.sh)"
STATE_STORAGE_ACCOUNT="$("${SCRIPT_DIR}"/get_state_storage_account_name.sh)"
STATE_CONTAINER_NAME="$("${SCRIPT_DIR}"/get_state_container_name.sh)"

[ "$(az group list --query "[?name=='${STATE_RG}'].name" --output tsv 2>/dev/null)" == "${STATE_RG}" ] || {
  az group create --name "${STATE_RG}" --location "${LOCATION}"
}

[ "$(az storage account list --query "[?name=='${STATE_STORAGE_ACCOUNT}'].name" --output tsv 2>/dev/null)" == "${STATE_STORAGE_ACCOUNT}" ] || {
  az provider register --namespace Microsoft.Storage
  echo "TODO wait to ensure Microsoft.Storage namespace is registered so that it is possible to spin Storage Account"
  sleep 120
  az storage account create --name "${STATE_STORAGE_ACCOUNT}" --resource-group "${STATE_RG}" --location "${LOCATION}" --sku Standard_LRS
}

[ "$(az storage container list --account-name "${STATE_STORAGE_ACCOUNT}" --query "[?name=='${STATE_CONTAINER_NAME}'].name" --output tsv 2>/dev/null)" == "${STATE_CONTAINER_NAME}" ] || {
  az storage container create --name "${STATE_CONTAINER_NAME}" --account-name "${STATE_STORAGE_ACCOUNT}"
}
