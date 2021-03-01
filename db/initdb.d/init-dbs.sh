#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER ss;
    CREATE DATABASE ss;
    GRANT ALL PRIVILEGES ON DATABASE ss TO ss;
    CREATE DATABASE "dataportal-test";
    GRANT ALL PRIVILEGES ON DATABASE "dataportal-test" TO dataportal;
EOSQL
