#!/bin/bash

echo "Running PubSub daemon: $(date +'%Y-%m-%dT%H:%M:%S%:z')"

i=0
# Attempt to start this service five times.
until [ $i -gt 5 ]
do
  drush helfi:azure:pubsub-listen

  if [[ "$?" -ne 0 ]]; then
    ((i=i+1))
    sleep 10
  fi
done
