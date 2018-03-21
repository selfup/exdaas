 docker cp $(docker ps --latest --quiet):/exdaas.tar.gz ./exdaas.tar.gz \
    && echo 'RELEASE COPIED' \
    && docker stop $(docker ps --latest --quiet)
