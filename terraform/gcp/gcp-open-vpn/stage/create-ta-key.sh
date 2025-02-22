#!/usr/bin/env bash
# Create CA cert for OpenVPN usage
ORG="${1:?ORG is mandatory}"

DIRNAME="$(dirname "$0")"
FILE="${DIRNAME}/target/${ORG}/ta.key"
[ -e "${FILE}" ] || {
  mkdir -p "${DIRNAME}/target/${ORG}"
  (
    cd "${DIRNAME}/target/${ORG}" || exit 6
    openvpn --genkey secret ta.key 2>/dev/null
  )
}
cat "${FILE}"
