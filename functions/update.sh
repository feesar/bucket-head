#!/bin/bash

if [ "$update" != true ] || ! isScheduledTime "update"
then
  writeLog "update" "Update disabled or not the time for an update"
  return 0
fi

writeLog "update" "Checking for server update"

if [[ $(serverManager "cu") == *"Update available"* ]]
then
  if isMonthlyUpdate && [ "$umod_update" = true ] && [[ $(oxidecheck) != $(date +%F) ]]
  then
    writeLog "update" "Waiting for oxide update"
    exit 0
  fi
  writeLog "update" "Doing server update"

  writeLog "update" "Stopping server"
  serverManager "stop"

  writeLog "update" "Updating server"
  serverManager "u"

  if [ "$umod_update" = true ]
  then
    if [ "$umod_backup_groups" = true ]
    then
      writeLog "update" "Backup Umod groups from oxide"
      mkdir $BASEDIR/tmp
      mv $executable_path/serverfiles/oxide/data/oxide.groups.data $BASEDIR/tmp
    fi

    writeLog "update" "Updating Umod"
    serverManager "mu"

    if [ "$umod_backup_groups" = true ]
    then
      writeLog "update" "Restoring Umod groups from temp"
      mv $BASEDIR/tmp/oxide.groups.data $executable_path/serverfiles/oxide/data/
      rm -rf $BASEDIR/tmp
    fi
  fi

  if isMonthlyUpdate
  then
    . $BASEDIR/functions/wipe.sh "devblog"
    return 0
  fi

  writeLog "update" "Starting server"
  serverManager "start"
else
  writeLog "update" "Monitoring server"
  serverManager "m"
fi
