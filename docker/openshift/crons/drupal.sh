#!/bin/bash

echo "Running Drupal cron"

while true
do
  drush cron
  sleep 600
done
