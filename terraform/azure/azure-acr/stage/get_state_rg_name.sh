#!/usr/bin/env bash
set -e

SUB_ID="$(az account show --query id -o tsv)"
SUB_NAME="$(az account list --all --query "[?id=='${SUB_ID}'].name" --output tsv)"

STATE_RG="${SUB_NAME}-gitops"

echo "${STATE_RG}"
