#!/bin/bash

function fetch-repo {
  if [[ -d "../$1/.git" ]]; then
    echo "Pulling '$1'"
    if ! git -C "../$1" pull --ff-only; then
      echo "ERROR: Conflicting changes detected. Please fix this manually."
    else
      current_branch="$(git -C "../$1" rev-parse --abbrev-ref HEAD)"
      default_branch="$(git -C "../$1" remote show origin | sed -n '/HEAD branch/s/.*: //p')"
      if [ "$current_branch" != "$default_branch" ]; then
        echo "WARN: Current branch '$current_branch' is not the default branch '$default_branch'"
      fi
    fi
  elif [ "$2" = true ]; then
    echo "Cloning '$1'"
    git -C .. clone "git@github.com:actris-cloudnet/$1.git"
  fi
  echo
}

# Required repositories.
fetch-repo dev-toolkit true
fetch-repo dataportal true
fetch-repo cloudnet-processing true
fetch-repo pid-service true
fetch-repo storage-service true
fetch-repo dataportal-fixtures true
fetch-repo citation-service true

# Optional repositories.
fetch-repo cloudnetpy false
fetch-repo cloudnetpy-qc false
fetch-repo dataportal-docs false
fetch-repo doppy false
fetch-repo mwrpy false
fetch-repo rpgpy false
fetch-repo voodoonet false
fetch-repo model-munger false
fetch-repo cloudnet-api-client false
fetch-repo ceilopyter false
