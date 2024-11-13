#!/bin/sh

if [ -z "$AMQ_BROKERS" ]; then
  exit 0
fi

if ! is_drupal_module_enabled "helfi_navigation"; then
  exit 0
fi

while true
do
 drush stomp:worker helfi_navigation_menu_queue --items-limit 100
done
