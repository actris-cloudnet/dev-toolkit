#!/bin/bash

set -eo pipefail
shopt -s expand_aliases

tmp_dir=tmp
cachefile_dp="$tmp_dir/dataportal-db.sql"
cachefile_ss="$tmp_dir/ss-db.sql"

mkdir -p "$tmp_dir"

echo "Fetching data..."
start_date=$(date --iso-8601 --date='7 days ago')
for table in instrument_upload model_upload regular_file model_file search_file; do
  oc exec service/postgres -i -- psql -U dataportal_ro dataportal > "$tmp_dir/$table.sql" << SQL
COPY (SELECT * FROM $table
      WHERE "measurementDate" >= '$start_date') TO STDOUT;
SQL
done
oc exec service/postgres -i -- psql -U dataportal_ro dataportal > "$tmp_dir/visualization.sql" << SQL
COPY (SELECT visualization.*
      FROM visualization
      JOIN regular_file
      ON "sourceFileUuid" = regular_file.uuid
      WHERE "measurementDate" >= '$start_date') TO STDOUT;
SQL
oc exec service/postgres -i -- psql -U dataportal_ro dataportal > "$tmp_dir/model_visualization.sql" << SQL
COPY (SELECT model_visualization.*
      FROM model_visualization
      JOIN model_file
      ON "sourceFileUuid" = model_file.uuid
      WHERE "measurementDate" >= '$start_date') TO STDOUT;
SQL
for table in regular_file model_file; do
  camel_table=${table%_*}File
  tmp_table=${table}_software_software
  oc exec service/postgres -i -- psql -U dataportal_ro dataportal > "$tmp_dir/$tmp_table.sql" << SQL
COPY (SELECT $tmp_table.*
      FROM $tmp_table
      JOIN $table
      ON "${camel_table}Uuid" = $table.uuid
      WHERE "measurementDate" >= '$start_date') TO STDOUT;
SQL
  tmp_table=collection_${table}s_$table
  oc exec service/postgres -i -- psql -U dataportal_ro dataportal > "$tmp_dir/$tmp_table.sql" << SQL
COPY (SELECT $tmp_table.*
      FROM $tmp_table
      JOIN $table
      ON "${camel_table}Uuid" = $table.uuid
      WHERE "measurementDate" >= '$start_date') TO STDOUT;
SQL
done
oc exec service/postgres -i -- psql -U dataportal_ro dataportal > "$tmp_dir/file_quality.sql" << SQL
COPY (SELECT file_quality.*
      FROM file_quality
      JOIN search_file
      ON file_quality."uuid" = search_file.uuid
      WHERE "measurementDate" >= '$start_date') TO STDOUT;
SQL
oc exec service/postgres -i -- psql -U dataportal_ro dataportal > "$tmp_dir/quality_report.sql" << SQL
COPY (SELECT quality_report.*
      FROM quality_report
      JOIN search_file
      ON quality_report."qualityUuid" = search_file.uuid
      WHERE "measurementDate" >= '$start_date') TO STDOUT;
SQL

oc exec service/postgres -- pg_dump -U dataportal_ro dataportal --exclude-table-data="download|instrument_upload|model_upload|regular_file|model_file|search_file|collection_model_files_model_file|model_file_software_software|regular_file_software_software|collection_regular_files_regular_file|model_visualization|visualization|file_quality|quality_report" > $cachefile_dp

oc exec service/postgres -- pg_dump -U ss_ro ss --schema-only > $cachefile_ss

for table in cloudnet-img cloudnet-product cloudnet-product-volatile; do
  oc exec service/postgres -i -- psql -U ss_ro ss > "$tmp_dir/$table.sql" << SQL
COPY (SELECT *
      FROM "$table"
      WHERE key not like 'legacy/%'
      AND key >= '${start_date//-/}') TO STDOUT;
SQL
done

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

echo "Inserting data..."
resetdb dataportal dataportal
psql dataportal dataportal < "$cachefile_dp"
for table in instrument_upload model_upload regular_file model_file search_file collection_model_files_model_file model_file_software_software regular_file_software_software collection_regular_files_regular_file model_visualization visualization file_quality quality_report; do
  psql dataportal dataportal -c "COPY \"$table\" FROM STDIN;" < "$tmp_dir/$table.sql"
done

resetdb ss ss
psql ss ss < $cachefile_ss
for table in cloudnet-img cloudnet-product cloudnet-product-volatile; do
  psql ss ss -c "COPY \"$table\" FROM STDIN;" < "$tmp_dir/$table.sql"
done
