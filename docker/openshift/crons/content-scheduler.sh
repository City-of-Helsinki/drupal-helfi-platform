#!/bin/bash

while true
do
  drush scheduler:cron -q
  sleep 60
done
