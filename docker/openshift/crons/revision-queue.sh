#!/bin/sh

if [ -z "$AMQ_BROKERS" ]; then
  exit 0
fi

while true
do
 drush stomp:worker helfi_api_base_revision --items-limit 100
done
