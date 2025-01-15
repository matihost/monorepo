#!/usr/bin/env bash
# Create self signed TLS certificate for provided CN
CN="${1:?CN is mandatory}"
DIRNAME="$(dirname "$0")"
CRT_FILE="${DIRNAME}/target/${CN}.crt"
[ -e "${CRT_FILE}" ] || {
  mkdir -p "${DIRNAME}/target"
  openssl req -x509 -sha256 -subj "/CN=${CN}" -days 365 -out "${CRT_FILE}" -newkey rsa:2048 -nodes -keyout "${DIRNAME}/target/${CN}.key" 2>/dev/null
}
cat "${CRT_FILE}"
