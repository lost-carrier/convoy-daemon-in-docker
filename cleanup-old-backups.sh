#!/bin/bash

BACKUP_MOUNT=$1
BACKUPS_TO_KEEP=3
CONVOY='convoy'
BACKUP_VOLUMES=`$CONVOY backup list $BACKUP_MOUNT | jq -c '.[] | .VolumeName' | sort | uniq`


log () {
    LOGDATE=`date --utc +"%Y-%m-%dT%H:%M:%S.%3NZ"`
    echo "$LOGDATE $1"
}


log "Starting to clean-up old backup..."
for BACKUP_VOLUME in $BACKUP_VOLUMES
do
    BACKUP_VOLUME=${BACKUP_VOLUME//[^a-zA-Z0-9-_]/}
    BACKUPS=`$CONVOY backup list $BACKUP_MOUNT | jq '[.[] | select(.VolumeName=="'$BACKUP_VOLUME'")]' | jq 'sort_by(.SnapshotName)' | jq '.[] | "\(.BackupURL)"' | head -n -$BACKUPS_TO_KEEP`
    for BACKUP in $BACKUPS
    do
        BACKUP=${BACKUP//\"/}
        log "Removing $BACKUP"
        RESULT=`$CONVOY backup delete $BACKUP`
    done
done
