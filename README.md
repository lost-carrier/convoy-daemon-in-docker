Intro
===
This will run a convoy daemon inside a docker container. I use this to schedule creation of backups with Rancher Convoy. Maybe it might be helpful for someone else, too. Comments, PR and stuff welcome!

Convoy you can find here: https://github.com/rancher/convoy

Limitations
---
- It works only with convoy-vfs!
- It only does full backups! (...no incremental ones...)

Build
===
Building the Docker image:
```
git clone <url-to-convoy-daemon-in-docker>
cd convoy-daemon
docker build -t losty/convoy-daemon:0.5.2-5 .
```

You should have some backup target volume present. I mount this from some Diskstation in case my local HDD will die. I placed my backup schedule as crontab directly there:
```
00 1 * * *  bash /cleanup-old-backups.sh vfs:///mnt/backup/ >> /mnt/backup/backup.log 2>1

00 0 * * *  bash /backup-all.sh vfs:///mnt/backup/ >> /mnt/backup/backup.log 2>1

...or...

00 0 * * 1,3,5 bash /create-backup.sh some-individual-volume vfs:///mnt/backup/ >> /mnt/backup/backup.log 2>1
00 0 * * 0,2,4 bash /create-backup.sh some-other-volume vfs:///mnt/backup/ >> /mnt/backup/backup.log 2>1
```

Now start the convoy deamon container:
```
docker run --detach \
    --name convoy \
    --restart=always \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    --volume /var/run/convoy/:/var/run/convoy/ \
    --volume /etc/docker/plugins:/etc/docker/plugins \
    --volume /var/lib/docker/volumes:/var/lib/docker/volumes \
    --mount 'type=volume,src=convoy-backup-mount,dst=/mnt/backup,volume-driver=local,volume-opt=type=nfs,volume-opt=device=diskstation:/volume1/backup-convoy,"volume-opt=o=addr=10.41.42.11,vers=4,rw"' \
    --env CRONTAB_FILE=/mnt/backup/backup.crontab \
    convoy-daemon:0.5.2-5
```

I recommend building some fancy shortcut:
```
echo "alias convoy='docker exec -ti convoy convoy'" >> ~/.bash_profile
```

Usage
===
Use may scripts as mentioned in the `backup.crontab` like this:
```
docker exec -it convoy /create-backup.sh elasticsearch-data vfs:///mnt/backup/
```

You can also create your backups by hand using convoy (this is basically what `/create-backup.sh` does):
```
convoy snapshot create elasticsearch-data --name elasticsearch-data-1
convoy backup create elasticsearch-data-1 --dest vfs:///mnt/backup/
convoy snaphot delete elasticsearch-data-1
```

Create new volume:
```
convoy create some-new-volume
```

List all backups:
```
convoy backup list vfs:///mnt/backup/
```

Restore a backup:
```
convoy create elasticsearch-data-restored --backup vfs:///mnt/backup/?backup=backup-e2f3349f6270499c\u0026volume=elasticsearch-data
```

Misc Commands
===
Collection of command you may find useful: 
```
convoy backup list vfs:///mnt/backup/ | jq '.[]' | jq -c -s 'sort_by(.SnapshotName)' | jq '.[] | "\(.SnapshotName), \(.BackupURL)"'

convoy backup delete "vfs:///mnt/backup/?backup=backup-b25f9ca4cf6d4a9a&volume=gogs-data"

convoy backup list vfs:///mnt/backup/ | jq -c 'map(select(.VolumeName | equals("mariadb")))'
convoy backup list vfs:///mnt/backup/ | jq -c 'map(select(.VolumeName=="my-services-db"))' | jq 'sort_by(.SnapshotName)' | jq '.[] | "\(.SnapshotName), \(.BackupURL)"'

convoy backup list vfs:///mnt/backup/ | jq -c '.[] | .VolumeName' | sort | uniq
```

More Info
===
- https://github.com/rancher/convoy
- https://github.com/rancher/container-crontab
- https://github.com/rancher/os/issues/706#issuecomment-168434624
- https://rancher.com/docs/os/v1.1/en/system-services/custom-system-services/#service-cron
- http://rancher.com/using-convoy-to-backup-and-recover-a-wordpress-mysql-database-with-docker/#more-2604
- https://stackoverflow.com/questions/23935141/how-to-copy-docker-images-from-one-host-to-another-without-via-repository