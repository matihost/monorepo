#!/usr/bin/env bash
set -e
set -x

# shellcheck disable=SC2034
GSA="${1}"

kubectl apply -f target/config-sync-operator.yaml

# TODO template config-managegemnt.template.yaml file
# kubectl apply -f target/config-management.yaml

# TODO run it after
# https://cloud.google.com/kubernetes-engine/docs/add-on/config-sync/how-to/installing#configuring-config-management-operator
# so that importer will appear
# kubectl annotate serviceaccount -n config-management-system importer iam.gke.io/gcp-service-account="${GSA}"
