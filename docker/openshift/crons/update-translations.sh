#!/bin/bash

sleep 10
drush locale:check || true
drush locale:update || true
drush helfi:locale-import helfi_platform_config || true
