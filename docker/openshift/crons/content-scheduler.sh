#!/bin/bash

while true
do
  drush scheduler:cron --nomsg --nolog
  sleep 60
done
