#!/usr/bin/env bash

./scripts/secret.sh \
    && echo 'CONTAINER WILL BUILD' \
    && docker-compose build
