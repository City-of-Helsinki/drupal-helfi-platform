#!/bin/sh

# Add the default sitemap to rebuild queue and let cron handle the generation.
drush simple-sitemap:rebuild-queue --variants=default
