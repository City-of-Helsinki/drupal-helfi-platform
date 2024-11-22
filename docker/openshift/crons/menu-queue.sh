#!/bin/sh

source /init.sh

if [ -z "$AMQ_BROKERS" ]; then
  exit 0
fi

if ! is_drupal_module_enabled "helfi_navigation"; then
  exit 0
fi

while true
do
  # Restart process every 12 hours.
  drush stomp:worker helfi_navigation_menu_queue --lease-time 43200
done
