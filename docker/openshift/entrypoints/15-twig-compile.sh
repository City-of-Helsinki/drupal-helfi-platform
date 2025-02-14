#!/bin/sh

# Populate twig caches.
if [ ! -d "/tmp/twig" ]; then
  drush twig:compile || true
fi
