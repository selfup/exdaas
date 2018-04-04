#!/usr/bin/env bash

if [ !$DETS_ROOT ]
then
  DETS_ROOT=./persistance_dir
fi

if [ -f "$DETS_ROOT/dets_counter" ]
  then $(rm -rf "$DETS_ROOT/*")
fi

iex -S mix phx.server
