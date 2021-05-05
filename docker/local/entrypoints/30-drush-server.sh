#!/bin/bash

sleep 10
until drush runserver http://127.0.0.1:8888; do echo "program ended with status $?"; done &
