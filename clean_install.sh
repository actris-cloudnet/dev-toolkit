#!/bin/bash

docker compose down

sudo rm -rf db/data
mkdir -p db/data

docker compose build

sudo rm -rf ../dataportal/backend/node_modules
sudo rm -rf ../dataportal/frontend/node_modules
sudo rm -rf ../dataportal/shared/node_modules
sudo rm -rf ../storage-service/node_modules

docker compose run dataportal-backend npm install
docker compose run dataportal-frontend npm install
docker compose run dataportal-frontend sh -c 'cd /shared && npm install'
docker compose run storage-service npm install
