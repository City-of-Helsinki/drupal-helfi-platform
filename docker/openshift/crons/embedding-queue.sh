#!/bin/bash

source /init.sh

if ! is_drupal_module_enabled "helfi_search"; then
  exit 0
fi

while true
do
  drush queue:run 'Drupal\helfi_search\Plugin\QueueWorker\EmbeddingQueue'
  # Sleep for 5 minutes.
  sleep 300
done
