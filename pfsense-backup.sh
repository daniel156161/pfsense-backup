#!/bin/sh
source "/scripts/borgBackup.sh"
source "/scripts/functions.sh"

##############################################################################################################################
# Main Execution
##############################################################################################################################
sepurator
echo "Starting Docker Container..."
sepurator

# check for required parameters
check_pfSense_vars_set

# borg backups vars set
check_borg_backup_vars

# check for optional parameters
check_pfSense_optional_vars

# set up variables
url=${PFSENSE_SCHEME}://${PFSENSE_IP}
timestamp=$(date +%Y%m%d%H%M%S)

print_container_info

if [ $cron -eq 1 ]; then
  if [ -z "$FROM_CRON" ]; then
    load_crontab_when_exists_or_create
  else
    run_backups
    cleanup_old_backups_when_set
  fi
else
  run_backups
fi
