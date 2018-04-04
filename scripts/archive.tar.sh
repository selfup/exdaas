#!/usr/bin/env bash

ARCHIVE=archive.tar.gz

if [ !$DETS_ROOT ]
then
  DETS_ROOT=./persistance_dir
fi

function createArchive() {
    tar -zcvf $ARCHIVE $DETS_ROOT
}

if [ -f $ARCHIVE ]
then
  rm $ARCHIVE && createArchive
else
  createArchive
fi
