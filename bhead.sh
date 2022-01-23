#!/bin/bash

EXECUTION_TIME=$(date +%s)
BASEDIR="$(cd $(dirname "$BASH_SOURCE") > /dev/null 2>&1 && pwd)"
AUTOLOAD=("config" "functions")

if [ $(cat $BASEDIR/lock/process.lock) = "1" ]
then
  exit 0
fi

echo "1" > $BASEDIR/lock/process.lock

for FOLDER in "${AUTOLOAD[@]}"
do
  for SCRIPT in "$BASEDIR"/"$FOLDER"/*
  do
    if [[ "$SCRIPT" == *"sample"* ]]
    then
      continue
    fi

    . $SCRIPT
  done
done

echo "0" > $BASEDIR/lock/process.lock