FROM alpine:latest

#ENV PFSENSE_IP=192.168.0.1
#ENV PFSENSE_USER=none
#ENV PFSENSE_PASS=none
#ENV PFSENSE_SCHEME=https
#ENV BACKUPNAME=router

# Install packages
RUN apk update ; apk upgrade
RUN apk add --no-cache wget tzdata bash bash-completion \
borgbackup openssh-client

RUN rm -rf /var/cache/apk/*
RUN mkdir -p /scripts

COPY scripts/ /scripts

COPY pfsense-backup.sh /
COPY backup.sh /

VOLUME ["/data"]
CMD ["/pfsense-backup.sh"]
