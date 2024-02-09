#!/usr/bin/env bash

# Installation procedure for log ingestion agent installation:
# https://cloud.ibm.com/docs/log-analysis?topic=log-analysis-config_agent_os_cluster

# CLUSTER_NAME="${1}"
# LOG_INGEST_KEY="${2}"

ibmcloud ks cluster config -c "${CLUSTER_NAME}" --admin

#TODO finish
