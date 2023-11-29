#!/bin/bash

echo "Running invalidate by cache tags: $(date +'%Y-%m-%dT%H:%M:%S%:z')"

tags="helfi_kymp_plans"

while true
do
  drush cache:tag -q "$tags"
  sleep 3600
done
