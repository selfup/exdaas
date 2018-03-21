./scripts/secret.sh \
    && echo 'TESTING APP' \
    && mix test \
    && echo 'CONTAINER WILL RUN AFTER BEING BUILT' \
    && docker-compose build \
    && docker-compose up
