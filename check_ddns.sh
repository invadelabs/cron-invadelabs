#!/bin/bash
# Drew Holt <drew@invadelabs.com>
# https://github.com/invadelabs/cron-invadelabs/blob/master/check_ddns.sh
# cron; */5 * * * * /root/scripts/check_ddns.sh
#
# Script to update google domains ddns with netrc credentials file

DDNS_HOST=nm.invadelabs.com

IP="$(dig +short myip.opendns.com @resolver1.opendns.com)"
DDNS_IP="$(dig +short @8.8.8.8 $DDNS_HOST)"
DATE="$(date '+%Y-%m-%d-%H:%M:%S%z')"

slack_msg () {
  if [ ! -f /root/scripts/slacktee.sh ]; then
    curl -sS -o /root/scripts/slacktee.sh https://raw.githubusercontent.com/course-hero/slacktee/master/slacktee.sh
    chmod 755 /root/scripts/slacktee.sh
  fi
  echo "$1" | \
  /root/scripts/slacktee.sh \
  --config /root/slacktee.conf \
  -a warning \
  -c general \
  -u "$(basename "$0")" \
  -i ipv4 \
  -t "$DDNS_HOST at $IP" > /dev/null;
  # -e "docker ps -a" "$DOCKER_STATUS "\
  # -t "Container $CONTAINER is $1 on $HOSTNAME" \
  # -p \
}

if [ ! "$IP" == "$DDNS_IP" ]; then
  CURL="$(curl --netrc-file /root/check_ddns.cred -sS "https://domains.google.com/nic/update?hostname=$DDNS_HOST&myip=$IP")"

  slack_msg "$DDNS_HOST IP updated on $DATE with $CURL"
fi

# https://user:pass@domains.google.com/nic/update?hostname=$DDNS_HOST&myip=$IP
