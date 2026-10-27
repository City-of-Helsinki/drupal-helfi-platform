#!/bin/bash

source /init.sh

if ! is_drupal_module_enabled "search_api"; then
  exit 0
fi

# The parallel tracker lets each worker claim its own items.
WORKERS=${SEARCH_INDEX_WORKERS:-4}

while true
do
  for i in $(seq 1 "$WORKERS"); do
    drush search-api:index &
  done
  wait
  # Sleep for 5 minutes.
  sleep 300
done
