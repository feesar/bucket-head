#!/bin/bash

isScheduledTime(){
  CHECK_PASS=true
  CONDITIONS=("minute" "hour" "day" "month" "week_day")
  DATE_FORMAT=("%-M" "%-H" "%-d" "%-m" "%-u")

  i=0
  for condition in "${CONDITIONS[@]}"
  do
    CONFIG_VALUE="$1_${condition}"
    CONDITION_VALUE=${!CONFIG_VALUE}
    CURRENT_VALUE=${DATE_FORMAT[i]}

    if echo "$CONDITION_VALUE" | grep '^[0-9]\{1,2\}' > /dev/null;
    then
      if [ "$CONDITION_VALUE" != "$(date -d @$EXECUTION_TIME +"$CURRENT_VALUE")" ]
      then
        CHECK_PASS=false;
      fi
    fi

    if echo "$CONDITION_VALUE" | grep '^\*/[0-9]\{1,2\}' > /dev/null;
    then
      if [ "$(($(date -d @$EXECUTION_TIME +"$CURRENT_VALUE")%${CONDITION_VALUE##*/}))" != "0" ]
      then
        CHECK_PASS=false;
      fi
    fi

    if echo "$CONDITION_VALUE" | grep '^[0-9]\{1,2\}-' > /dev/null;
    then
      IFS='-' read -r -a RANGE <<< "$CONDITION_VALUE"

      if [ "${RANGE[0]}" -gt "$(date -d @$EXECUTION_TIME +"$CURRENT_VALUE")" ] || [ "${RANGE[1]}" -lt "$(date -d @$EXECUTION_TIME +"$CURRENT_VALUE")" ]
      then
        CHECK_PASS=false;
      fi
    fi

    i=$((i+1))
  done

  if [ "$CHECK_PASS" = true ]
  then
    return 1
  fi

  return 0
}

setLock(){
  echo "$2" > $BASEDIR/lock/$1.lock
}

getLock(){
  echo "$(cat $BASEDIR/lock/$1.lock)"
}

writeLog(){
  if [ "$log_actions" = true ]
  then
    echo "[$1 $(date '+%d/%m/%Y %H:%M:%S')] $2" >> $BASEDIR/bhead.log
  fi
}