#!/usr/bin/env sh

set -e
set -o pipefail

# Ensure that the GITHUB_TOKEN secret is included
if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "Set the GITHUB_TOKEN env variable."
  exit 1
fi

mkdir /release && tar -C public/ -czvf /release/website-latest.tgz ./