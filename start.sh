#!/bin/bash
set -e

mode=$1

if test "$mode" == 'remote'; then
  set -o xtrace
  cd ../storage-service
  git-crypt unlock
  cd -
  SS_MODE=remote docker-compose up
elif test "$mode" == 'local'; then
  set -o xtrace
  SS_MODE=local docker-compose up
else
  echo "Usage: $0 remote|local"
  exit 1
fi
