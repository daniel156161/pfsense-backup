FROM alpine:latest

ENV PFSENSE_IP=192.168.0.1
ENV PFSENSE_USER=backupuser
ENV PFSENSE_PASS=changeme
ENV PFSENSE_SCHEME=https

RUN apk update ; apk upgrade ; apk add wget ; apk add --no-cache tzdata ; apk add --no-cache bash

COPY pfsense-backup.sh /
VOLUME ["/data"]
CMD ["/pfsense-backup.sh"]
