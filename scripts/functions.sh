##############################################################################################################################
# Funktionen
##############################################################################################################################
function sepurator {
  echo "======================================================================================"
}

function check_pfSense_vars_set() {
  local errors=0

  if [ -z "$PFSENSE_IP" ]; then echo "Must provide PFSENSE_IP" ; errors=$(($errors + 1)) ; fi
  if [ -z "$PFSENSE_USER" ]; then echo "Must provide PFSENSE_USER" ; errors=$(($errors + 1)); fi
  if [ -z "$PFSENSE_PASS" ]; then echo "Must provide PFSENSE_PASS" ; errors=$(($errors + 1)); fi
  if [ -z "$PFSENSE_SCHEME" ]; then echo "Must provide PFSENSE_SCHEME" ; errors=$(($errors + 1)); fi
  if [ -z "$BACKUPNAME" ]; then BACKUPNAME=$PFSENSE_IP; fi

  if [ $errors -ne 0 ]; then exit 1; fi
}

function check_pfSense_optional_vars() {
  if [ -z "$PFSENSE_CRON_SCHEDULE" ]; then cron=0 ; else cron=1 ; fi
  if [ -z "$PFSENSE_BACK_UP_RRD_DATA" ]; then
    getrrd=""
  else
    if [ "$PFSENSE_BACK_UP_RRD_DATA" == "0" ] ; then
      getrrd="&donotbackuprrd=yes"
    else
      getrrd=""
    fi
  fi
  if [ -z "$PFSENSE_BACKUP_DESTINATION_DIR" ]; then
    destination="/data"
  else
    destination="$PFSENSE_BACKUP_DESTINATION_DIR"
  fi
}

function check_borg_backup_vars() {
  local errors=0

  if [ ! -z "$BORG_BACKUP_TRUE" ]; then
    if [ "$BORG_REPO" ]; then echo "Musst provice BORG_REPO"; errors=$(($errors + 1)); fi
    if [ "$BORG_CREATE_PARAMS" ]; then echo "Musst provice BORG_CREATE_PARAMS"; errors=$(($errors + 1)); fi
    if [ "$BORG_PRUNE_PARAMS" ]; then echo "Musst provice BORG_PRUNE_PARAMS"; errors=$(($errors + 1)); fi
  fi

  if [ $errors -ne 0 ]; then exit 1; fi
}

function load_crontab_when_exists_or_create() {
  if [ -f "$destination/crontab.txt" ]; then
    echo "* Load Crontab $destination/crontab.txt"
    crontab "$destination/crontab.txt"
  else
    echo "* Create $destination/crontab.txt"
    echo "$PFSENSE_CRON_SCHEDULE FROM_CRON=1 /pfsense-backup.sh" >> "$destination/crontab.txt"
    crontab "$destination/crontab.txt"
  fi
  sepurator
  crond -f
}

function do_backup() {
  wget -qO- --keep-session-cookies --save-cookies cookies.txt \
    --no-check-certificate ${url}/diag_backup.php \
    | grep "name='__csrf_magic'" | sed 's/.*value="\(.*\)".*/\1/' > csrf.txt

  wget -qO- --keep-session-cookies --load-cookies cookies.txt \
    --save-cookies cookies.txt --no-check-certificate \
    --post-data "login=Login&usernamefld=${PFSENSE_USER}&passwordfld=${PFSENSE_PASS}&__csrf_magic=$(cat csrf.txt)" \
    ${url}/diag_backup.php  | grep "name='__csrf_magic'" \
    | sed 's/.*value="\(.*\)".*/\1/' > csrf2.txt

  wget --keep-session-cookies --load-cookies cookies.txt --no-check-certificate \
    --post-data "download=download${getrrd}&__csrf_magic=$(head -n 1 csrf2.txt)" \
    ${url}/diag_backup.php -q -O ${destination}/config-${BACKUPNAME}-${timestamp}.xml
  return_value=$?
  if [ $return_value -eq 0 ]; then
    echo "Backup saved as ${destination}/config-${BACKUPNAME}-${timestamp}.xml"
  else
    echo "Backup failed"
    exit 1
  fi

  rm cookies.txt csrf.txt csrf2.txt
}

function run_backups() {
  echo "* Running backups"
  do_backup
  if [ ! -z "$BORG_BACKUP_TRUE" ]; then
    create_borg_backup "$BACKUPNAME" "${destination}/config-${BACKUPNAME}-${timestamp}.xml"
    purge_borg_backup "$BACKUPNAME"
  fi
  sepurator
}

function cleanup_old_backups_when_set() {
  if [ ! -z $keepfiles ]; then
    remove=$(ls -d -1tr $destination/*.xml | tail -n +$keepfiles | head -n1)
    if [ ! -z $remove ]; then
      del=$(ls $destination/*.xml | head -n -$keepfiles)
      if [ ! -z $del ]; then
        rm -f $del
        echo "Backup removed at $del"
      fi
    fi
  fi
}

function print_container_info {
  sepurator
  echo "* Backup - Name: $BACKUPNAME"
  sepurator
  echo "* pfSense - Url: $url"
  echo "* pfSense - User: $PFSENSE_USER"
  sepurator
}
