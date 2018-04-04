#!/usr/bin/env bash

echo 'GRABBING AND COMPILING DEPENDENCIES' \
    && mix deps.get \
    && mix deps.compile \
    && echo 'TESTING APP' \
    && mix test
