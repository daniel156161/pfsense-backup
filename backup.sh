#!/bin/sh
source "/scripts/borgBackup.sh"
source "/scripts/functions.sh"

url=${PFSENSE_SCHEME}://${PFSENSE_IP}
timestamp=$(date +%Y%m%d%H%M%S)

run_backups
