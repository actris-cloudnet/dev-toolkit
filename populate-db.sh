#!/bin/bash

export PGHOST=localhost
export PGPORT=54321
export PGUSER=dataportal
export PGPASSWORD=dev

cachefile="remote-db.tmp.sql"

if test "$1" == '-u' -o -e $cachefile; then
  if [ -z "$DATAPORTAL_SSH" ]; then
    echo "Environment variable DATAPORTAL_SSH must be set, i.e user@host"
    exit 1
  fi

  echo "Fetching remote db..."
  dropdb dataportal
  createdb dataportal
  ssh -C "$DATAPORTAL_SSH" "pg_dump dataportal" | tee $cachefile | psql dataportal
else
  psql dataportal < $cachefile
fi
