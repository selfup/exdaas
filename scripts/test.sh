./scripts/secret.sh \
    && echo 'GRABBING AND COMPILING DEPENDENCIES' \
    && mix deps.get \
    && mix deps.compile \
    && echo 'TESTING APP' \
    && mix test \
    && echo 'CONTAINER WILL RUN AFTER BEING BUILT' \
    && docker-compose build \
    && docker-compose up
