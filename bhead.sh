#!/bin/bash

EXECUTION_TIME="$(date +%s)"
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)"
AUTOLOAD=("config" "functions")

if [ "$(cat $BASEDIR/lock/process.lock)" = "1" ]
then
  exit 0
fi

echo "1" > $BASEDIR/lock/process.lock

for folder in "${AUTOLOAD[@]}"
do
  for script in "$BASEDIR"/"$folder"/*
  do
    if [[ "$script" == *"sample"* ]]
    then
      continue
    fi

    . $script
  done
done

echo "0" > $BASEDIR/lock/process.lock