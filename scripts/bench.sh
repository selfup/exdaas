#!/usr/bin/env bash

LOG_FILE=.results.log

function cflag () {
  if [ "$1" == "-c" ]
  then
    echo "--> entire benchmark output:
      updated in $(pwd)/$logfile
    "
  else
    git checkout -- $logfile
  fi
}

# if you pass the -c flag
# the script will keep changes in git for the logfile

ab \
  -n 50000 \
  -c 500 \
  -k -v 1 \
  -H "Accept-Encoding: gzip, deflate" \
  -T "application/json" \
  -p ./scripts/bench.data.json http://0.0.0.0:4000/api > $LOG_FILE \
  && echo "" \
  && echo "--> results:
    $(grep seconds $LOG_FILE)
    $(grep -w second $LOG_FILE)
  " \
  && cflag $1 \
