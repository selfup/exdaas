#!/usr/bin/env bash

P_DIR="./persistance_dir"

if [ -d $P_DIR ]
then
    echo "ALREADY MKDIR $P_DIR"
else
    echo 'MAKING DEFAULT PERSISTANCE DIR' \
        && mkdir $P_DIR
fi
