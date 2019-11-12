#!/bin/bash

BACKUP_MOUNT=$1
CONVOY="convoy"
VOLUMES=`$CONVOY list | jq 'keys | .[]' | uniq | sed -e 's/^"//' -e 's/"$//'`


log () {
    LOGDATE=`date --utc +"%Y-%m-%dT%H:%M:%S.%3NZ"`
    echo "$LOGDATE $1"
}


log "Starting to backup..."
for VOLUME in $VOLUMES; do
    log "Backing up $VOLUME..."
    bash /create-backup.sh $VOLUME $BACKUP_MOUNT
done
log "Done with all backups!"
