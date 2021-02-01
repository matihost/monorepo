#!/usr/bin/env bash

gcloud services enable \
  container.googleapis.com \
  gkeconnect.googleapis.com \
  gkehub.googleapis.com \
  anthos.googleapis.com \
  multiclusteringress.googleapis.com \
  cloudresourcemanager.googleapis.com

HUB_PROJECT_ID=$(gcloud config get-value core/project)
CLUSTER_LOCATION="us-central1-a"
CLUSTER_NAME="shared-dev"

gcloud iam service-accounts create gke-hub

gcloud projects add-iam-policy-binding "${HUB_PROJECT_ID}" \
  --member="serviceAccount:gke-hub@${HUB_PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/gkehub.connect"

gcloud iam service-accounts keys create hub.json \
  --iam-account="gke-hub@${HUB_PROJECT_ID}.iam.gserviceaccount.com" \
  --project="${HUB_PROJECT_ID}"

# add cluster to same hub
gcloud container hub memberships register "${CLUSTER_NAME}-${CLUSTER_LOCATION}" \
  --project="${HUB_PROJECT_ID}" \
  --gke-uri="https://container.googleapis.com/v1/projects/${HUB_PROJECT_ID}/zones/${CLUSTER_LOCATION}/clusters/${CLUSTER_NAME}" \
  --service-account-key-file=./hub.json

gcloud alpha container hub ingress enable \
  --config-membership="projects/${HUB_PROJECT_ID}/locations/global/memberships/${CLUSTER_NAME}-${CLUSTER_LOCATION}"
