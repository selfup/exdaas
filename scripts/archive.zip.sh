#!/usr/bin/env bash

if [ !$DETS_ROOT ]
then
  DETS_ROOT=./persistance_dir
fi

if [ -d archive.zip ]
then
  rm -rf archive.zip && zip -r archive.zip $DETS_ROOT
else
  zip archive.zip $DETS_ROOT
fi
