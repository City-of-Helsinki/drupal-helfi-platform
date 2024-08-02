#!/bin/bash

source /init.sh

if ! is_drupal_module_enabled "helfi_react_search"; then
  exit 0
fi

while true
do
  # Allow migrations to be run every 3 hours and reset stuck migrations every 12 hours.
  drush migrate:import linked_events_keywords --interval 10800 --reset-threshold 43200 --no-progress

  # Sleep for 12 hours
  sleep 86400
done
