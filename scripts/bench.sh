logfile=.results.log

ab \
  -n 5000 \
  -c 100 \
  -k -v 1 \
  -H "Accept-Encoding: gzip, deflate" \
  -T "application/json" \
  -p ./scripts/bench.data.json http://0.0.0.0:4000/api > $logfile \
  && echo "" \
  && echo "--> results:
    $(grep seconds $logfile)
    $(grep -w second $logfile)
  "

# if you pass the -c flag
# the script will keep changes in git for the logfile

if [ "$1" == "-c" ]
then
  echo "--> entire benchmark output:
    updated in $(pwd)/$logfile
  "
else
  git checkout -- $logfile
fi
