#!/bin/bash
source "../build-functions.sh"
source "../build-config.sh"

DOCKER_IMAGE_NAME="daniel156161/pfsense-backup"

function run_docker_container {
  echo "Running..."
  docker run -d \
    -e PFSENSE_IP="" \
    -e PFSENSE_USER="" \
    -e PFSENSE_PASS="" \
    -e PFSENSE_SCHEME="https" \
    -e PFSENSE_CRON_SCHEDULE="0 0 * * 0" \
    -e TZ="Europe/Vienna" \
    "$DOCKER_IMAGE_NAME:$GIT_BRANCH"
}

case "$1" in
  run)
    run_docker_container
    ;;
  build)
    build_docker_image "$DOCKER_IMAGE_NAME:$GIT_BRANCH"
    ;;
  *)
    echo "Usage: $0 {run|build}"
    exit 1
    ;;
esac
