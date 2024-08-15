#!/bin/sh
docker compose down
sudo rm -rf db/data
mkdir -p db/data
