#!/bin/sh

# Run sitemap indexing
drush simple-sitemap:rebuild-queue --variants=default
drush simple-sitemap:generate
