#!/bin/bash

if [ "$wipe" != true ]
then
  writeLog "wipe" "Wipe is disabled"
  return 0
fi

if isMonthlyUpdate && [ "$1" != "devblog" ]
then
  writeLog "wipe" "Waiting for an update of the month or update already made"
  return 0
fi

if isScheduledTime "wipe" || isMonthlyUpdate
then
  writeLog "wipe" "Doing server wipe"

  writeLog "wipe" "Stopping server"
  serverManager "stop"

  if [ $(getLock "cycle") = "$wipe_bps" ]
  then
    writeLog "wipe" "Server full wipe"
    serverManager "fw"
    setLock "cycle" "1"
  else
    writeLog "wipe" "Server map wipe"
    serverManager "mw"
    setLock "cycle" "$(($(getLock "cycle")+1))"
  fi

  if [ "$wipe_plugins_data" = true ]
  then
    writeLog "wipe" "Removing plugins data"

    for FILE in "${delete[@]}"
    do
      rm $executable_path/serverfiles/$FILE
    done
  fi

  writeLog "wipe" "Starting server"
  serverManager "start"
fi
