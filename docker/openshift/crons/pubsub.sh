#!/bin/bash

if [ -z "$DRUPAL_PUBSUB_VAULT" ]; then
  echo "PubSub is not configured, exiting."
  exit 0
fi

echo "Running PubSub daemon: $(date +'%Y-%m-%dT%H:%M:%S%:z')"

while true
do
  # PubSub process exists with success return code after
  # certain number of messages and should then be restarted.
  drush helfi:azure:pubsub-listen || exit 1
done
