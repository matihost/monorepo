#!/usr/bin/env bash
# Create CA cert for OpenVPN usage
ORG="${1:?ORG is mandatory}"
COUNTRY="${2:-PL}"
STATE="${3:-XX}"
CITY="${4:-YYY}"
EMAIL="${5:-"me@me.me"}"
FILE_SUFFIX="${6:-crt}" # or key

DIRNAME="$(dirname "$0")"
RESULT_FILE="${DIRNAME}/target/${ORG}/ca.${FILE_SUFFIX}"

[ -e "${RESULT_FILE}" ] || {
  mkdir -p "${DIRNAME}/target/${ORG}"
  cp "${DIRNAME}/openssl.cnf" "${DIRNAME}/target/${ORG}"
  (
    cd "${DIRNAME}/target/${ORG}" || exit 6
    openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 \
      -extensions easyrsa_ca -keyout ca.key -out ca.crt \
      -subj "/C=${COUNTRY}/ST=${STATE}/L=${CITY}/O=${ORG}/emailAddress=${EMAIL}" \
      -config openssl.cnf 2>/dev/null
  )
}
cat "${RESULT_FILE}"
