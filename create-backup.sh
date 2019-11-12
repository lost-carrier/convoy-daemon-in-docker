#!/bin/bash

VOLUME="$1"
DESTINATION="$2"
DATE=`date --utc +"%Y%m%d%H%M%S"`
SNAPSHOT="${VOLUME}_${DATE}"

log () {
    LOGDATE=`date --utc +"%Y-%m-%dT%H:%M:%S.%3NZ"`
    echo "$LOGDATE $1"
}

log "$VOLUME: creating snaphot $SNAPSHOT..."
convoy snapshot create $VOLUME --name $SNAPSHOT

log "$VOLUME: moving $SNAPSHOT to $DESTINATION..."
convoy backup create $SNAPSHOT --dest $DESTINATION

log "$VOLUME: removing $SNAPSHOT..."
convoy snapshot delete $SNAPSHOT

log "$VOLUME: backup done!"

