#!/bin/bash

DOCKER_IMAGE_NAME="daniel156161/pfsense-backup"
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

build_docker_image() {
  TAG="$1"

  echo "Building..."
  docker build -t "$DOCKER_IMAGE_NAME:$TAG" .
}

run_docker_container() {
  echo "Running..."
  docker run -d \
    -e PFSENSE_IP="" \
    -e PFSENSE_USER="" \
    -e PFSENSE_PASS="" \
    -e PFSENSE_SCHEME="https" \
    -e PFSENSE_CRON_SCHEDULE="0 0 * * 0" \
    -e TZ="Europe/Vienna" \
    "$DOCKER_IMAGE_NAME":"$GIT_BRANCH"
}

if [ "$GIT_BRANCH" == "master" ]; then
  GIT_BRANCH="latest"
fi

case "$1" in
  run)
    run_docker_container
    ;;
  build)
    build_docker_image "$GIT_BRANCH"
    ;;
  upload)
    build_docker_image "$GIT_BRANCH"
    docker push "$DOCKER_IMAGE_NAME:$GIT_BRANCH"
    ;;
  *)
    echo "Usage: $0 {build|upload}"
    exit 1
    ;;
esac
