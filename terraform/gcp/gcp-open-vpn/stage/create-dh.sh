#!/usr/bin/env bash
# Create CA cert for OpenVPN usage
ORG="${1:?ORG is mandatory}"

DIRNAME="$(dirname "$0")"
FILE="${DIRNAME}/target/${ORG}/dh2048.pem"
[ -e "${FILE}" ] || {
  mkdir -p "${DIRNAME}/target/${ORG}"

  # Normally it should run
  # openssl dhparam -out dh2048.pem 2048 2>/dev/null
  # but it takes really long...
  cat >"${FILE}" <<EOF
-----BEGIN DH PARAMETERS-----
MIIBCAKCAQEA4kf0aBV747+KHlrIXhj/6uqhHq+5gxHHnwm0sHaZ12PKLqojWJ4k
d7Tv/IKCjBUNuBVZVQ//v1suj+u6mE/qix9QyMLpmT/tlKPb1wYkChFjjFVpMiFv
8H0Rqqv2uD3aJdkkXBd4xKKfULzyl/HCNMRPKbFEaT42Yjli0tOFLGgEe2BGJPNg
96RCCrScHOCcAStOOeCm2l6pINVsf4gupYzl5cgsX1Ua4mvf3LPKo2ivbdgY+4/1
0zpLRbCc7KgPCs2XQHPTcqueCEjS42AdKYJj0ZmabLcm1BSoWXV9ujMxuwnOxL8n
Xuo09rig2uk6ntzF3+lwFdlOVXYc4W5nSwIBAg==
-----END DH PARAMETERS-----
EOF
}
cat "${FILE}"
