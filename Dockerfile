FROM ubuntu:latest

RUN apt-get update
RUN apt-get install -y cron
RUN apt-get install -y jq 
RUN apt-get install -y wget 

ADD start-convoy.sh /start-convoy.sh
ADD create-backup.sh /create-backup.sh
ADD cleanup-old-backups.sh /cleanup-old-backups.sh
ADD backup-all.sh /backup-all.sh
ADD config.cfg /var/lib/rancher/convoy/convoy.cfg

RUN wget -q "https://github.com/rancher/convoy/releases/download/v0.5.2/convoy.tar.gz" \
	&& tar zxvpf convoy.tar.gz \
	&& cp convoy/convoy* /usr/bin/ \
    && rm -rf convoy.tar.gz \
    && chmod +x /start-convoy.sh \
    && chmod +x /create-backup.sh \
    && chmod +x /cleanup-old-backups.sh \
    && chmod +x /backup-all.sh

ENTRYPOINT ["/start-convoy.sh"]