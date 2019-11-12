#!/bin/bash

/usr/sbin/cron
/usr/bin/crontab $CRONTAB_FILE

DOCKER_VOLUMES=/var/lib/docker/volumes
DOCKER_PLUGINS=/etc/docker/plugins

if [ "$@"="" ]; then
    if [ ! -d $DOCKER_PLUGINS ]; then
        mkdir -p $DOCKER_PLUGINS
    fi

    echo "unix:///var/run/convoy/convoy.sock" > $DOCKER_PLUGINS/convoy.spec

    CMD="daemon --drivers vfs --driver-opts vfs.path=$DOCKER_VOLUMES --cmd-timeout 10m"
else
    CMD=$@
fi

exec /usr/bin/convoy $CMD