#!/usr/bin/env bash

./scripts/secret.sh
./scripts/first.boot.sh

echo 'GRABBING AND COMPILING DEPENDENCIES' \
    && mix deps.get \
    && mix deps.compile \
    && echo 'TESTING APP' \
    && mix test \
    && echo 'CONTAINER WILL RUN AFTER BEING BUILT' \
    && docker-compose up --build \
