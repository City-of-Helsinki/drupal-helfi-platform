#!/usr/bin/env bash
#
# Prevents Composer from running outside of a container.
#
# Run by the "pre-command-run" Composer script, so it runs before every
# Composer command and stops it by exiting with a non-zero status.

is_true() {
  case "$1" in
    [Tt][Rr][Uu][Ee]|1) return 0 ;;
    *) return 1 ;;
  esac
}

# Allow running in CI, like in GitHub Actions.
is_true "${CI:-}" && exit 0

# Set by the City of Helsinki Drupal images, also during the image builds.
is_true "${CONTAINER_RUNNING:-}" && exit 0

# Created by Docker and Podman in the running containers.
if [[ -f /.dockerenv || -f /run/.containerenv ]]; then
  exit 0
fi

echo "Composer must be run inside the Docker container. Run \"make shell\" and run the command there." >&2
exit 1
