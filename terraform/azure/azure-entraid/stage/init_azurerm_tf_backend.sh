#!/usr/bin/env bash
set -e

SUB_ID="$(az account show --query id -o tsv)"
SUB_NAME="$(az account list --query "[?id=='${SUB_ID}'].name" --output tsv)"
LOCATION=polandcentral
STATE_RG="${SUB_NAME}-gitops"
# Storage account name must be between 3 and 24 characters in length and use numbers and lower-case letters only.
STATE_STORAGE_ACCOUNT="${SUB_NAME}gitops"
STATE_CONTAINER_NAME="${SUB_NAME}"

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
