#!/bin/sh

./clean_db.sh

docker compose build

sudo rm -rf ../dataportal/backend/node_modules
sudo rm -rf ../dataportal/frontend/node_modules
sudo rm -rf ../dataportal/shared/node_modules
sudo rm -rf ../storage-service/node_modules

docker compose run --rm dataportal-backend npm install
docker compose run --rm dataportal-frontend npm install
docker compose run --rm dataportal-frontend sh -c 'cd /shared && npm install'
docker compose run --rm storage-service npm install
