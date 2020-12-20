#!/usr/bin/env bash

function add-role-profile() {
  ROLE_NAME=${1:?RoleName not provided}
  ROLE_ARN="$(aws iam get-role --role-name="${ROLE_NAME}" --query='Role.Arn' 2>/dev/null)"

  [ -z "${ROLE_ARN}" ] && {
    echo "Unable to get role ${ROLE_NAME}"
    exit 1
  }
  [ "$(grep profile ~/.aws/config | grep -c ami-builder)" -gt 0 ] && {
    echo "Profile ami-builder already present in ~/.aws/confg"
    exit 1
  }
  echo -e "[profile ${ROLE_NAME}]\nrole_arn = $(echo -n "${ROLE_ARN}" | sed 's/"//g')\nsource_profile = default\nregion = us-east-1" >>~/.aws/config &&
    echo "Run: 'awsp ${ROLE_NAME}'to swith to ${ROLE_NAME} role for the rest of shell session"
}

ROLE_NAME=${1:?Usage: $(basename "$0") roleName}

add-role-profile "${ROLE_NAME}"
