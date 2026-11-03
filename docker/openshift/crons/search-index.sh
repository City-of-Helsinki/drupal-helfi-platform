#!/bin/bash

source /init.sh

if ! is_drupal_module_enabled "search_api"; then
  exit 0
fi

while true
do
  # Only the parallel tracker lets each worker claim its own items, so start
  # multiple workers only when it's in use. Check this on every run, since the
  # configuration can change on deploy.
  WORKERS=1
  if [[ "$(drush config:get search_api.settings default_tracker --include-overridden --format=string 2>/dev/null)" == "parallel" ]]; then
    WORKERS=${SEARCH_INDEX_WORKERS:-4}
  fi

  for i in $(seq 1 "$WORKERS"); do
    drush search-api:index &
  done
  wait
  # Sleep for 5 minutes.
  sleep 300
done
