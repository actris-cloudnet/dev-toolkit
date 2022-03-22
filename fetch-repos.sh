#!/bin/bash

function fetch-repo {
  if [[ -d "../$1" ]]; then
    echo "Pulling '$1'"
    if ! git -C "../$1" pull --ff-only; then
      echo "ERROR: Conflicting changes detected. Please fix this manually."
      return
    fi
    current_branch="$(git -C "../$1" rev-parse --abbrev-ref HEAD)"
    default_branch="$(git -C "../$1" remote show origin | sed -n '/HEAD branch/s/.*: //p')"
    if [ "$current_branch" != "$default_branch" ]; then
      echo "WARN: Current branch '$current_branch' is not the default branch '$default_branch'"
    fi
  else
    echo "Cloning '$1'"
    git -C .. clone "git@github.com:actris-cloudnet/$1.git"
  fi
}

fetch-repo dev-toolkit
fetch-repo dataportal
fetch-repo data-processing
fetch-repo pid-service
fetch-repo storage-service
fetch-repo dataportal-resources
