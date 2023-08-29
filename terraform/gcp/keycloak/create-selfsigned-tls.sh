#!/usr/bin/env bash
# Create self signed TLS certificate for provided CN
CN="${1:?CN is mandatory}"
DIRNAME="$(dirname "$0")"
[ -e "${DIRNAME}/target/${CN}.crt" ] || {
  openssl req -x509 -sha256 -subj "/CN=${CN}" -days 365 -out "${DIRNAME}/target/${CN}.crt" -newkey rsa:2048 -nodes -keyout "${DIRNAME}/target/${CN}.key" 2>/dev/null
}
cat "${DIRNAME}/target/${CN}.crt"
