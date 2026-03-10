#!/bin/sh

if [ ! -z "$NO_OBFUSCATE_DATA" ]; then
    echo "NO_OBFUSCATE_DATA is set. Skipping the step."
    return
fi

# Obfuscate user data
drush sql:sanitize
# Convert file schemes for Stage file proxy
drush sql-query "UPDATE file_managed SET uri = REPLACE(uri, 'azure://', 'public://');"
