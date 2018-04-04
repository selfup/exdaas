#!/usr/bin/env bash

PS_AQ=$(docker ps -aq)
IMAGES_Q=$(docker images -q)

if [ !$PS_AQ ] || [ !$IMAGES_Q ]
then
    echo 'NOTHING TO STOP OR DELETE'
else
    echo ' STOPPING ALL CONTAINERS' \
        && docker stop $PS_AQ \
        && echo 'DELETING ALL CONTAINERS' \
        && docker rm $PS_AQ \
        && echo 'DELETING ALL IMAGES' \
        && docker rmi $IMAGES_Q
fi
