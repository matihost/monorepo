#!/usr/bin/env bash
set -e

SUB_ID="$(az account show --query id -o tsv)"
SUB_NAME="$(az account list --all --query "[?id=='${SUB_ID}'].name" --output tsv)"

# Storage account name must be between 3 and 24 characters in length and use numbers and lower-case letters only.
# remove hyphens and underscores
STATE_STORAGE_ACCOUNT="${SUB_NAME//[-_]/}"
# convert to lowercase
STATE_STORAGE_ACCOUNT="${STATE_STORAGE_ACCOUNT,,}"
# get first 19 characters  +gitops resulting max 24 characters
STATE_STORAGE_ACCOUNT="${STATE_STORAGE_ACCOUNT:0:18}gitops"

echo "${STATE_STORAGE_ACCOUNT}"
