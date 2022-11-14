#!/bin/bash

set -eo pipefail
shopt -s expand_aliases

cachefile_dp="tmp/dataportal-db.sql.gz"
cachefile_ss="tmp/ss-db.sql.gz"

mkdir -p tmp

if [ "$1" == '-u' ] || [ ! -f "$cachefile_dp" ] || [ ! -f "$cachefile_ss" ]; then
  echo "Fetching remote db..."
  oc project cloudnet-app > /dev/null
  echo -n "Fetching dataportal dump... "
  oc exec deploy/postgres -- sh -c "pg_dump -U dataportal dataportal | gzip" > $cachefile_dp
  echo "OK"
  echo -n "Fetching ss dump... "
  oc exec deploy/postgres -- sh -c "pg_dump -U ss ss | gzip" > $cachefile_ss
  echo "OK"
else
  echo "Using cached dumps..."
fi

alias psql="docker compose exec -T db psql"
alias dropdb="docker compose exec -T db dropdb"
alias createdb="docker compose exec -T db createdb"

function resetdb {
  dropdb --if-exists "$1"
  createdb -O "$2" "$1"
}

docker compose up -d db
echo -n "Waiting for local db... "
until psql -c "select 1" > /dev/null 2>&1; do
  sleep 1
done
echo "OK"

resetdb dataportal dataportal
gunzip -c $cachefile_dp | psql dataportal dataportal

resetdb ss ss
gunzip -c $cachefile_ss | psql ss ss
