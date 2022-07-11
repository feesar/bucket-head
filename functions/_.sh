#!/bin/bash
oxidecheck(){
  curl -s 'https://assets.umod.org/games/rust.json' | \
    python3 -c "import json,sys;obj=json.load(sys.stdin);print(obj['latest_release_at']);" | cut -f1 -d" "
}

isScheduledTime(){
  CHECK_PASS=true
  CONDITIONS=("minute" "hour" "day" "month" "week_day" "month_week")
  DATE_FORMAT=("%-M" "%-H" "%-d" "%-m" "%-u" "custom")

  i=0
  for CONDITION in "${CONDITIONS[@]}"
  do
    CONFIG_VALUE="$1_${CONDITION}"
    CONDITION_VALUE=${!CONFIG_VALUE}

    if [ "${DATE_FORMAT[i]}" = "custom" ]
    then
      if [ "$CONDITION" = "month_week" ]
      then
        CURRENT_VALUE=$((($(date -d @$EXECUTION_TIME +%-d)-1)/7+1))
      fi
    else
      CURRENT_VALUE=$(date -d @$EXECUTION_TIME +"${DATE_FORMAT[i]}")
    fi

    if echo "$CONDITION_VALUE" | grep '^[0-9]\{1,2\}' > /dev/null;
    then
      if [ "$CONDITION_VALUE" != "$CURRENT_VALUE" ]
      then
        CHECK_PASS=false;
      fi
    fi

    if echo "$CONDITION_VALUE" | grep '^\*/[0-9]\{1,2\}' > /dev/null;
    then
      if [ "$(($CURRENT_VALUE%${CONDITION_VALUE##*/}))" != "0" ]
      then
        CHECK_PASS=false;
      fi
    fi

    if echo "$CONDITION_VALUE" | grep '^[0-9]\{1,2\}-' > /dev/null;
    then
      IFS='-' read -r -a RANGE <<< "$CONDITION_VALUE"

      if [ "${RANGE[0]}" -gt "$CURRENT_VALUE" ] || [ "${RANGE[1]}" -lt "$CURRENT_VALUE" ]
      then
        CHECK_PASS=false;
      fi
    fi

    i=$((i+1))
  done

  if [ "$CHECK_PASS" = true ]
  then
    return 0
  fi

  return 1
}

isMonthlyUpdate(){
  devblog_minute="*"
  devblog_hour="*"
  devblog_day="*"
  devblog_month="*"
  devblog_week_day="4"
  devblog_month_week="1"

  if [ "$wipe_wait_month_update" != true ]
  then
    return 1
  fi

  if isScheduledTime "devblog"
  then
    return 0
  fi

  return 1;
}

serverManager(){
  cd $executable_path

  COMMAND="./rustserver $1"
  eval OUTPUT=\$\($COMMAND\)

  if [ "$1" = "start" ]
  then
    if [[ "$OUTPUT" != *"Rust is already running"* ]]
    then
      while true ; do
        if tmux capture-pane -pt rustserver | grep -q 'SteamServer Connected' ; then
          break
        fi
        sleep 1
      done
    fi
  fi

  if [ "$1" = "stop" ]
  then
    if [[ "$OUTPUT" != *"Rust is already stopped"* ]]
    then
      while true ; do
        if ! tmux has-session -t rustserver ; then
          break
        fi
        sleep 1
      done
    fi
  fi

  echo "$OUTPUT";
}

writeLog(){
  if [ "$log_actions" = true ]
  then
    echo "[$1 $(date '+%d/%m/%Y %H:%M:%S')] $2" >> $BASEDIR/bhead.log
  fi
}

setLock(){
  echo "$2" > $BASEDIR/lock/$1.lock
}

getLock(){
  echo "$(cat $BASEDIR/lock/$1.lock)"
}
