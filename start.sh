#!/bin/bash
set -e

mode=$1

if test "$mode" == 'remote'; then
  cd ../secrets
  git-crypt unlock
  export $(cat private/s3-ro.env | xargs)
  cd -
  SS_MODE=remote docker-compose up
elif test "$mode" == 'local'; then
  SS_MODE=local docker-compose up
else
  echo "Usage: $0 remote|local"
  exit 1
fi
