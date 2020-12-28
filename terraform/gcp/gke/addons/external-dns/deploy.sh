#!/usr/bin/env bash

# shellcheck disable=SC2155
export GCP_PROJECT="$(gcloud config get-value project)"
export GCP_GSA="edns-sa"

template=$(cat values.template.yaml)

helm install external-dns \
  --namespace=external-dns \
  --create-namespace \
  -f <(eval "echo -e \"${template}\"") \
  bitnami/external-dns
