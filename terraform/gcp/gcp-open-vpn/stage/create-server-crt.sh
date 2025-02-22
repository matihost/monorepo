#!/usr/bin/env bash
# Create CA cert for OpenVPN usage
ORG="${1:?ORG is mandatory}"
CN_SERVER="${2:-${ORG}.vpn.server}"
COUNTRY="${3:-PL}"
STATE="${4:-XX}"
EMAIL="${5:-"me@me.me"}"
FILE_SUFFIX="${6:-crt}" # or key

DIRNAME="$(dirname "$0")"
RESULT_FILE="${DIRNAME}/target/${ORG}/server.${FILE_SUFFIX}"
[ -e "${RESULT_FILE}" ] || {
  mkdir -p "${DIRNAME}/target/${ORG}"
  cp "${DIRNAME}/openssl.cnf" "${DIRNAME}/target/${ORG}"
  (
    cd "${DIRNAME}/target/${ORG}" || exit 6
    touch index.txt
    echo "01" >serial
    openssl req -new -nodes -config openssl.cnf -extensions server \
      -CA ca.crt -CAkey ca.key \
      -keyout server.key -out server.crt \
      -subj "/C=${COUNTRY}/ST=${STATE}/O=${ORG}/CN=${CN_SERVER}/emailAddress=${EMAIL}" 2>/dev/null

    # Create server key and cert
    # openssl req -new -nodes -config openssl.cnf -extensions server \
    #   -keyout server.key -out server.csr \
    #   -subj "/C=${COUNTRY}/ST=${STATE}/O=${ORG}/CN=${CN_SERVER}/emailAddress=me@myhost.mydomain"
    # openssl ca -batch -config openssl.cnf -extensions server \
    #   -out server.crt -in server.csr
    rm serial* index.txt*
  )
}
cat "${RESULT_FILE}"
