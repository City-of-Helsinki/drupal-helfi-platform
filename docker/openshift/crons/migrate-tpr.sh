#!/bin/bash

while true
do
  # Allow migrations to be run every 3 hours and reset stuck migrations every 12 hours.
  drush migrate:import tpr_unit --no-progress --reset-threshold 43200 --interval 10800
  drush migrate:import tpr_service --no-progress --reset-threshold 43200 --interval 10800
  drush migrate:import tpr_errand_service --no-progress --reset-threshold 43200 --interval 10800
  drush migrate:import tpr_service_channel --no-progress --reset-threshold 43200 --interval 10800
  # Sleep for 6 hours.
  sleep 21600
done
