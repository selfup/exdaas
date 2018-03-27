if [ -f dets_counter ]; then $(rm dets_*); fi \
  && iex -S mix phx.server
