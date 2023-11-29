#!/bin/bash

echo "Starting hearings migration: $(date)"

while true
do
  drush mim helfi_hearings --reset-threshold 43200 --interval 1800
  sleep 900
done
