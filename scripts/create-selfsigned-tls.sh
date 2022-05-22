#!/usr/bin/env bash
# Create self signed TLS certificate for provided CN
CN="${1:?CN is mandatory}"

FILENAME="${CN}-$(date -Is)"
openssl req -x509 -sha256 -subj "/CN=${CN}" -days 365 -out "${FILENAME}.crt" -newkey rsa:2048 -nodes -keyout "${FILENAME}.key"
