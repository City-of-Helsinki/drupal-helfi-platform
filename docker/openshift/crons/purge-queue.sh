#!/bin/bash

echo "Running purge queue: $(date)"

while true
do
  echo "Flushing purge queue: $(date)"
  drush p:queue-work --no-interaction -q --finish
  # Sleep for 60 seconds.
  sleep 60
done
