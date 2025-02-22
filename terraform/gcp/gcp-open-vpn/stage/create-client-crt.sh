#!/usr/bin/env bash
# Create CA cert for OpenVPN usage
ORG="${1:?ORG is mandatory}"
CN_CLIENT="${2:-${ORG}.vpn.client}"
COUNTRY="${3:-PL}"
STATE="${4:-XX}"
EMAIL="${5:-"me@me.me"}"
FILE_SUFFIX="${6:-crt}" # or key

DIRNAME="$(dirname "$0")"
RESULT_FILE="${DIRNAME}/target/${ORG}/client.${FILE_SUFFIX}"
[ -e "${RESULT_FILE}" ] || {
  mkdir -p "${DIRNAME}/target/${ORG}"
  cp "${DIRNAME}/openssl.cnf" "${DIRNAME}/target/${ORG}"
  (
    cd "${DIRNAME}/target/${ORG}" || exit 6
    touch index.txt
    echo "01" >serial

    openssl req -new -nodes -config openssl.cnf \
      -keyout client.key -out client.csr \
      -subj "/C=${COUNTRY}/ST=${STATE}/O=${ORG}/CN=${CN_CLIENT}/emailAddress=${EMAIL}" 2>/dev/null
    openssl ca -batch -config openssl.cnf \
      -out client.crt -in client.csr 2>/dev/null

    rm serial* index.txt*
  )
}
cat "${RESULT_FILE}"
