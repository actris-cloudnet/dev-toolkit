#!/bin/bash

set -eo pipefail
shopt -s expand_aliases

cachefile_dp="tmp/dataportal-db.sql"
cachefile_ss="tmp/ss-db.sql"

mkdir -p tmp

if [ "$1" == '-u' ] || [ ! -f "$cachefile_dp" ] || [ ! -f "$cachefile_ss" ]; then
  echo "Fetching remote db..."
  oc project cloudnet-app > /dev/null
  echo -n "Fetching dataportal dump... "
  oc exec service/postgres -- pg_dump -U dataportal_ro dataportal > $cachefile_dp
  (tail $cachefile_dp | grep -q 'PostgreSQL database dump complete') && echo 'OK' || (echo 'FAILED'; exit 1)
  echo -n "Fetching ss dump... "
  oc exec service/postgres -- pg_dump -U ss_ro ss > $cachefile_ss
  (tail $cachefile_ss | grep -q 'PostgreSQL database dump complete') && echo 'OK' || (echo 'FAILED'; exit 1)
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
psql dataportal dataportal < $cachefile_dp

resetdb ss ss
psql ss ss < $cachefile_ss
