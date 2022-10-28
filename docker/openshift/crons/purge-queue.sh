#!/bin/bash

function has_items {
  NUM_ITEMS=$(drush p:queue-stats --format=json | jq .number_of_items)

  if [ "$NUM_ITEMS" -gt "0" ]; then
    return 0
  fi
  return 1
}

while true
do
  if has_items; then
    drush p:queue-work --no-interaction --finish --format=json | jq --arg DATE "$(date +'%Y-%m-%dT%H:%M:%S%:z')" -c '.[] |= . + {"date" : $DATE}'
  fi
  # Sleep for 60 seconds.
  sleep 60
done
