#!/bin/sh
set -e
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 dbname"
    exit 1
fi
port="$(docker compose port db 5432)"
pgcli "postgresql://$1:dev@$port/$1"
