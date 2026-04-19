#!/usr/bin/env bash
set -euo pipefail

CN="${1:?Provide CN}"
DAYS="${2:-365}"
HOST="$(hostname)"

CA_CERT="/usr/local/share/ca-certificates/${HOST}-root-ca.crt"
CA_KEY="/usr/local/share/ca-certificates/${HOST}-root-ca.key"

OUTDIR="$(pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
umask 077

[[ -f "$CA_CERT" ]] || {
  echo "Missing CA cert"
  exit 1
}
sudo test -f "$CA_KEY" || {
  echo "Missing CA key (sudo)"
  exit 1
}

KEY_PEM="$OUTDIR/${CN}.key"
CRT_PEM="$OUTDIR/${CN}.crt"
P12="$OUTDIR/${CN}.pfx" # aka PKCS#12 format contains both cert and key, useful for Azure Key Vault storage

openssl genpkey -algorithm RSA \
  -out "$KEY_PEM" \
  -pkeyopt rsa_keygen_bits:2048

CSR="$TMP/${CN}.csr"
openssl req -new \
  -key "$KEY_PEM" \
  -out "$CSR" \
  -subj "/CN=${CN}"

SAN="$TMP/san.ext"
cat >"$SAN" <<EOF
subjectAltName=DNS:${CN}
basicConstraints=CA:FALSE
keyUsage=critical,digitalSignature,keyEncipherment
extendedKeyUsage=serverAuth
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer
EOF

sudo openssl x509 -req \
  -in "$CSR" \
  -CA "$CA_CERT" \
  -CAkey "$CA_KEY" \
  -CAcreateserial \
  -out "$CRT_PEM" \
  -days "$DAYS" \
  -sha256 \
  -extfile "$SAN"

openssl pkcs12 -export \
  -out "$P12" \
  -inkey "$KEY_PEM" \
  -in "$CRT_PEM" \
  -certfile "$CA_CERT" \
  -name "$CN" \
  -passout pass:
