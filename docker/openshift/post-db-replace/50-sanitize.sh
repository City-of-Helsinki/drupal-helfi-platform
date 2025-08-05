#!/bin/sh

if [ ! -z "$NO_OBFUSCATE_DATA" ]; then
    echo "NO_OBFUSCATE_DATA is set. Skipping the step."
    return
fi

# Obfuscate user data
drush sql:sanitize
