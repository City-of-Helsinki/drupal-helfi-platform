#!/bin/bash

while true
do
  echo "Running cron: $(date +'%Y-%m-%dT%H:%M:%S%:z')\n"
  drush cron
  # Sleep for 10 minutes.
  sleep 600
done
