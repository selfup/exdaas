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

if [ $BENCH_LOG ]
then
  echo "--> entire benchmark output:
    updated in $(pwd)/$logfile
  "
else
  git checkout -- $logfile
fi
