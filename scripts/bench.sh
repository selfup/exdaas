ab \
  -n 10000 \
  -c 500 \
  -k -v 1 \
  -H "Accept-Encoding: gzip, deflate" \
  -T "application/json" \
  -p ./scripts/bench.data.json http://0.0.0.0:4000/api > .results.log
