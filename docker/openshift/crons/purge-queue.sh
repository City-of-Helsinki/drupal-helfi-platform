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
    RESULT=$(drush p:queue-work --no-interaction --finish --format=json | jq --arg DATE "$(date +'%Y-%m-%dT%H:%M:%S%:z')" -c '.[] |= . + {"date" : $DATE}')
    # RESULT is an array of json objects. Process each result and
    # only output the failed items.
    echo $RESULT | jq -c '.[]' | while read LINE; do
      if [ $(echo "$LINE" | jq .failed) -gt "0" ]; then
        echo $LINE
      fi
    done
  fi

  sleep 60
done
