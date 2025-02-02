#!/usr/bin/env bash
# Create self signed TLS certificate for provided CN
CN="${1:?CN is mandatory}"
RETURN_KEY="${2:-"false"}"
DIRNAME="$(dirname "$0")"
CRT_FILE="${DIRNAME}/target/${CN}.crt"
[ -e "${CRT_FILE}" ] || {
  mkdir -p "${DIRNAME}/target"
  openssl req -x509 -sha256 -subj "/CN=${CN}" -days 365 -out "${CRT_FILE}" -newkey rsa:2048 -nodes -keyout "${DIRNAME}/target/${CN}.key" 2>/dev/null
}
[[ "${RETURN_KEY}" == "true" ]] && {
  cat "${DIRNAME}/target/${CN}.key"
  exit 0
}
cat "${CRT_FILE}"
