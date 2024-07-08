#!/usr/bin/env bash

function usage() {
  echo -e "Usage: $(basename "$0") [-p|--profile profileName] [-s source-profile] roleName

Create a swithing role profile in AWS ~/.aws/config file

Samples:
# creates a profile named ReadOnly@account1 for switching to role ReadOnly from source profile user@account1
$(basename "$0") -p ReadOnly@account1 -s user@account1 ReadOnly


# creates a profile named ReadOnly@account1 for switching to role ReadOnly from default profile
$(basename "$0") -p ReadOnly@account1 ReadOnly
"
}

while [[ "$#" -gt 0 ]]; do
  case $1 in
  -h | --help | help)
    usage
    exit 1
    ;;
  -r | --target-role)
    ROLE_NAME="$2"
    shift
    ;;
  -p | --profile)
    PROFILE_NAME="$2"
    shift
    ;;
  -s | --source-profile)
    SOURCE_PROFILE="$2"
    shift
    ;;
  *) PARAMS+=("$1") ;; # save it in an array for later
  esac
  shift
done
set -- "${PARAMS[@]}" # restore positional parameters

ROLE_NAME=${ENV:-${PARAMS[0]}}

if [[ -z "$ROLE_NAME" ]]; then
  usage
  exit 1
fi

function add-role-profile() {
  PROFILE_NAME="${1}"
  ROLE_NAME="${2}"
  SOURCE_PROFILE="${3:-default}"
  ROLE_ARN="$(aws iam get-role --role-name="${ROLE_NAME}" --query='Role.Arn' 2>/dev/null)"

  [ -z "${ROLE_ARN}" ] && {
    echo "Unable to get role ${ROLE_NAME}"
    exit 1
  }
  [ "$(grep profile ~/.aws/config | grep -c "${PROFILE_NAME}")" -gt 0 ] && {
    echo "Profile ${PROFILE_NAME} already present in ~/.aws/confg"
    exit 1
  }
  echo -e "[profile ${PROFILE_NAME}]\nrole_arn = $(echo -n "${ROLE_ARN}" | sed 's/"//g')\nsource_profile = ${SOURCE_PROFILE}\nregion = us-east-1" >>~/.aws/config &&
    echo "Run: 'awsume ${PROFILE_NAME}' to switch to ${ROLE_NAME} role for the rest of shell session"
}

add-role-profile "${PROFILE_NAME}" "${ROLE_NAME}" "${SOURCE_PROFILE}"
