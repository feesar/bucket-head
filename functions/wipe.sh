#!/bin/bash

MONTHLY_UPDATE=false

devblog_minute="*"
devblog_hour="*"
devblog_day="1-7"
devblog_month="*"
devblog_week_day="4"

if [ "$wipe" != true ]
then
  writeLog "wipe" "Wipe is disabled"
  return 0
fi

if [ "$wipe_wait_month_update" = true ] && ! isScheduledTime "devblog"
then
  writeLog "wipe" "Waiting for an update of the month"

  LGSM_UPDATE_TIMESTAMP="$(cat $executable_path/lgsm/lock/lastupdate.lock)"
  LGSM_UPDATE_DATE="$(date -d @$LGSM_UPDATE_TIMESTAMP +%d-%m-%Y)"

  if [ "$LGSM_UPDATE_DATE" != "$(date -d @$EXECUTION_TIME +%d-%m-%Y)" ]
  then
    writeLog "wipe" "Update of the month is not made yet"
    return 0
  fi

  MONTHLY_UPDATE=true
fi

if [ "$MONTHLY_UPDATE" = true ] || ! isScheduledTime "wipe" && isScheduledTime "devblog"
then
  writeLog "wipe" "Doing server wipe"

  cd $executable_path

  writeLog "wipe" "Stopping rust server"
  ./rustserver stop
  sleep 30

  if [ $(getLock "cycle") = "$wipe_bps" ]
  then
    writeLog "wipe" "Doing full wipe"
    echo "Y" | ./rustserver wa
    setLock "cycle" "1"
  else
    writeLog "wipe" "Doing map wipe"
    echo "Y" | ./rustserver wi
    setLock "cycle" "$(($(getLock "cycle")+1))"
  fi

  if [ "$wipe_plugins_data" = true ]
  then
    writeLog "wipe" "Removing plugins temp data"

    file=0
    while true
    do
      PLUGIN_ROW="pd$file"
      PLUGIN_FILE=${!PLUGIN_ROW}

      if [ ! -n "$PLUGIN_FILE" ]
      then
        break;
      fi

      rm $executable_path/serverfiles/$PLUGIN_FILE

      file=$((file+1))
    done
  fi

  writeLog "wipe" "Updating map seed"
  if [ "$map_seed" = "random" ]
  then
    map_seed=$(( $(tr -cd 0-9 </dev/urandom | head -c 3) % 9999999))
  fi
  sed -i -- 's/^seed=.*/seed="'$map_seed'"/g' $executable_path/lgsm/config-lgsm/rustserver/$lgsm_config

  sleep 30
  writeLog "wipe" "Starting rust server"
  ./rustserver start
fi