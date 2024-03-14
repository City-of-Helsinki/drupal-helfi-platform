#!/bin/bash

while true
do
  # Allow migrations to be run every 3 hours and reset stuck migrations every 12 hours.
  drush migrate:import linked_events_keywords --interval 10800 --reset-threshold 43200 --no-progress

  # Sleep for 12 hours
  sleep 86400
done
