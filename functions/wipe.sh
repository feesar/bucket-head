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
    WIPE_TYPE="FULL"
  else
    writeLog "wipe" "Server map wipe"
    serverManager "mw"
    setLock "cycle" "$(($(getLock "cycle")+1))"
    WIPE_TYPE="MAP"
  fi

  if [ "$wipe_plugins_data" = true ]
  then
    writeLog "wipe" "Removing plugins data"

    for FILE in "${delete[@]}"
    do
      rm $executable_path/serverfiles/$FILE
    done
  fi

  writeLog "wipe" "Updating map seed"
  if [ "$map_seed" = "random" ]
  then
    map_seed=$((1 + RANDOM*RANDOM % 2147483647))
  fi
  sed -i -- 's/^seed=.*/seed="'$map_seed'"/g' $executable_path/lgsm/config-lgsm/rustserver/$lgsm_config

  writeLog "wipe" "Starting server"
  serverManager "start"

  if [ "$wipe_webhook" != false ]
  then
    curl --max-time 30 --data "wipe=$WIPE_TYPE" $wipe_webhook
  fi
fi
