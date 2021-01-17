#!/usr/bin/env bash
CN="${1:?CN is mandatory}"
openssl req -x509 -sha256 -subj "/CN=${CN}" -days 365 -out "${CN}.crt" -newkey rsa:2048 -nodes -keyout "${CN}.key"
