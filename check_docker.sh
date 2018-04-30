#!/bin/bash
# Drew Holt <drew@invadelabs.com>
# Slack one message if the docker containers running state is false
# Slack one message once it's running state is true
# /root/check_docker.sh

CONTAINER="nagios4"
STATUS="$(docker inspect -f '{{.State.Running}}' $CONTAINER)"
IP="$(hostname -I | cut -f1 -d" ")"
DOCKER_STATUS="$(docker ps -a | grep $CONTAINER)"
LOCK_FILE="/tmp/docker.down"

slack_msg () {
  echo "Container $CONTAINER is $1 on $HOSTNAME" | \
  /root/slacktee.sh \
  --config /root/slacktee.conf \
  -e "docker ps -a" "$DOCKER_STATUS "\
  -t "Container $CONTAINER is $1 on $HOSTNAME" \
  -a "$2" \
  -p \
  -c alerts \
  -u "$(basename "$0")" \
  -i boom \
  -l http://"$IP":8080 > /dev/null;
}

case "$STATUS" in
  false)
    if [ ! -f $LOCK_FILE ]; then
      MESSAGE="not running"
      COLOR="danger"
      slack_msg "$MESSAGE" "$COLOR"
      # create a lock file to only alert once
      touch "$LOCK_FILE"
    fi
    ;;
  true)
    if [ -f $LOCK_FILE ]; then
      MESSAGE="running"
      COLOR="good"
      slack_msg "$MESSAGE" "$COLOR"
      # remove lock file
      rm "$LOCK_FILE"
    fi
    ;;
  *)
    echo "$STATUS $DOCKER_STATUS"
    exit 1
esac
