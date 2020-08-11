FROM alpine:latest

RUN apk update ; apk upgrade ; apk add wget ; apk add --no-cache tzdata ; apk add --no-cache bash
COPY pfsense-backup.sh /
VOLUME ["/data"]
CMD ["/pfsense-backup.sh"]
