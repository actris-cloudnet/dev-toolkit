#!/bin/bash

export PGHOST=localhost
export PGPORT=54321
export PGUSER=dataportal
export PGPASSWORD=dev

cachefile_dp="tmp/dataportal-db.sql"
cachefile_ss="tmp/ss-db.sql"

if test "$1" == '-u' -o ! -e "$cachefile_db" -o ! -e "$cachefile_db"; then
  if test -z "$DATAPORTAL_SSH" -o -z "$CLOUDNET_SSH"; then
    echo "Environment variables DATAPORTAL_SSH and CLOUDNET_SSH must be set, i.e user@host"
    exit 1
  fi

  mkdir -p tmp

  echo "Fetching remote db..."
  dropdb dataportal
  createdb dataportal
  ssh -C "$DATAPORTAL_SSH" "pg_dump dataportal" | tee $cachefile_dp | psql dataportal

  export PGUSER=ss
  dropdb ss
  createdb ss
  ssh -C "$CLOUDNET_SSH" "pg_dump ss" | tee $cachefile_ss | psql ss
else
  dropdb dataportal
  createdb dataportal
  psql dataportal < $cachefile_dp

  export PGUSER=ss
  dropdb ss
  createdb ss
  psql ss < $cachefile_ss
fi
