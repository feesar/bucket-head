#!/bin/bash

if [ "$update" != true ] || isScheduledTime "update"
then
  writeLog "update" "Update disabled or not the time for an update"
  return 0
fi

cd $executable_path

writeLog "update" "Checking for LGSM update"
./rustserver u
sleep 300

LGSM_UPDATE_TIMESTAMP="$(cat $executable_path/lgsm/lock/lastupdate.lock)"
LGSM_UPDATE_DATE="$(date -d @$LGSM_UPDATE_TIMESTAMP +%d-%m-%Y)"

if [ "$LGSM_UPDATE_DATE" = "$(date -d @$EXECUTION_TIME +%d-%m-%Y)" ]
then
  writeLog "update" "Last LGSM update is made today"

  if [ "$umod_update" != true ]
  then
    writeLog "[update] Umod update disabled"
    return 0
  fi

  if [ $(date -d @$(getLock "update") +%d-%m-%Y) != "$(date -d @$EXECUTION_TIME +%d-%m-%Y)" ]
  then
    writeLog "update" "Updating Umod"

    writeLog "update" "Stopping rust server"
    ./rustserver stop
    sleep 30

    writeLog "update" "Updating LGSM mods"
    ./rustserver mu
    sleep 120

    if [ "$umod_backup_groups" = true ]
    then
      writeLog "update" "Restoring Umod groups from temp"
      cp $BASEDIR/tmp/oxide.groups.data $executable_path/serverfiles/oxide/data/
    fi

    setLock "update" "$(date +%s)"

    writeLog "update" "Starting rust server"
    sleep 30
    ./rustserver start
  fi
fi