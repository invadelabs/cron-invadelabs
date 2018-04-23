#!/bin/bash
# Drew Holt <drew@invadelabs.com>
# Slack one message if the docker containers running state is false
# Slack one message once it's running state is true
# /root/check_docker.sh

STATUS="$(docker inspect -f '{{.State.Running}}' nagios4)"
IP="$(hostname -I | cut -f1 -d" ")"
DOCKER_STATUS="$(docker ps -a | grep nagios4)"
LOCK_FILE="/tmp/docker.down"

send_msg () {
  echo "$1" | \
  /root/slacktee.sh \
  --config /root/slacktee.conf \
  -e "docker ps -a" "$DOCKER_STATUS "\
  -t "Nagios $2 on $HOSTNAME" \
  -a "$3" \
  -p \
  -c alerts \
  -u "$(basename "$0")" \
  -i boom \
  -l http://"$IP":8080 > /dev/null;
}

if [ "$STATUS" == "false" ]; then
  if [ ! -f $LOCK_FILE ]; then
    MESSAGE="Nagios container not running on $HOSTNAME."
    STATE="down"
    COLOR="danger"
    send_msg "$MESSAGE" "$STATE" "$COLOR"
    # create a lock file to only alert once
    touch "$LOCK_FILE"
  fi
elif [ "$STATUS" == "true" ]; then
  if [ -f $LOCK_FILE ]; then
    MESSAGE="Nagios container running on $HOSTNAME."
    STATE="up"
    COLOR="good"
    send_msg "$MESSAGE" "$STATE" "$COLOR"
    # remove the lock file
    rm "$LOCK_FILE"
  fi
fi
