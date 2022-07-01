#!/usr/bin/env bash
# Creates CN-date.key and CN-date.csr file for CN  and Alt Names
#
# Usage: create-tls-csr.sh CN  [ALT_NAME ALT_NAME ...]
# Sample: create-tls-csr.sh www.matihost.pl edu.matihost.pl supersite.matihost.pl
#
# To check validity of CSR file:
# openssl req -text -noout -verify -in filename.csr

CN="${1:?CN is mandatory}"

shift

ALT_NAMES="$*"

CSR_TEMPLATE="
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
C = PL
ST = Poland
L = KRK
O = MyCompany
OU = Web
CN = ${CN}

[v3_req]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth

$(
  [ $# -gt 0 ] && {
    echo -e "subjectAltName = @alt_names \\n[alt_names]"
    i=1
    for ALT_NAME in ${ALT_NAMES}; do
      echo "DNS.${i} = ${ALT_NAME}"
      i=$((i + 1))
    done
  }
)
"

FILENAME="${CN}-$(date -Is)"
openssl req -new -out "${FILENAME}.csr" -newkey rsa:2048 -nodes -sha256 -keyout "${FILENAME}.key" -config <(echo -e "${CSR_TEMPLATE}")
