#!/bin/bash

function fetch-repo {
  if [[ -d "../$1" ]]; then
    echo "Pulling $1"
    git -C "../$1" pull
  else
    echo "Cloning $1"
    git -C .. clone "git@github.com:actris-cloudnet/$1.git"
  fi
}

fetch-repo dev-toolkit
fetch-repo dataportal
fetch-repo data-processing
fetch-repo pid-service
fetch-repo storage-service
fetch-repo dataportal-resources
