#!/bin/sh

if [ -z "$AMQ_BROKERS" ]; then
  exit 0
fi

while true
do
  # Restart process every 12 hours.
  drush stomp:worker helfi_api_base_revision --lease-time 43200
done
