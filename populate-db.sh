#!/bin/bash

export PGHOST=localhost
export PGPORT=54321
export PGUSER=dataportal
export PGPASSWORD=dev

cachefile_dp="tmp/dataportal-db.sql"
cachefile_ss="tmp/ss-db.sql"

mkdir -p tmp

function resetdb {
  dropdb $1
  createdb $1
}

docker-compose up -d db
echo -n "Waiting for local db... "
until docker-compose exec db psql -c "select 1" > /dev/null 2>&1
do
  sleep 1
done
echo "OK"

if test "$1" == '-u' -o ! -e "$cachefile_dp" -o ! -e "$cachefile_ss"; then
  echo "Fetching remote db..."
  if test -z "$DATAPORTAL_SSH" -o -z "$CLOUDNET_SSH"; then
    echo "Environment variables DATAPORTAL_SSH and CLOUDNET_SSH must be set, i.e user@host"
    exit 1
  fi

  resetdb dataportal
  ssh -C "$DATAPORTAL_SSH" "pg_dump dataportal" | tee $cachefile_dp | psql dataportal

  export PGUSER=ss
  resetdb ss
  ssh -C "$CLOUDNET_SSH" "pg_dump ss" | tee $cachefile_ss | psql ss
else
  echo "Using cached db..."

  resetdb dataportal
  psql dataportal < $cachefile_dp

  resetdb ss
  psql -U ss ss < $cachefile_ss
fi
