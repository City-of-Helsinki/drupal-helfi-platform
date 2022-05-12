#!/bin/bash

echo "Running content-scheduler"

while true
do
  drush scheduler:cron -q
  sleep 60
done
