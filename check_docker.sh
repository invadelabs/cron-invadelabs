#!/bin/bash
# Drew Holt <drew@invadelabs.com>
# https://github.com/invadelabs/cron-invadelabs/blob/master/check_docker.sh
# cron; */1 * * * * /root/scripts/check_docker.sh
#
# Slack one message if container isn't running
# Slack one message when the container is running again

LIST="nagios4 bind docker-elk_logstash docker-elk_kibana docker-elk_elasticsearch nightscout"

slack_msg () {
  if [ ! -f /root/scripts/slacktee.sh ]; then
    curl -sS -o /root/scripts/slacktee.sh https://raw.githubusercontent.com/course-hero/slacktee/master/slacktee.sh
    chmod 755 /root/scripts/slacktee.sh
  fi
  echo "Container $CONTAINER is $1 on $HOSTNAME" | \
  /root/scripts/slacktee.sh \
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

for CONTAINER in $LIST; do

  STATUS="$(docker inspect -f '{{.State.Running}}' "$CONTAINER")"
  IP="$(hostname -I | cut -f1 -d" ")"
  DOCKER_STATUS="$(docker ps -a | grep "$CONTAINER")"
  LOCK_FILE="/tmp/docker.down-$CONTAINER"

  case "$STATUS" in
    false)
      if [ ! -f "$LOCK_FILE" ]; then
        MESSAGE="not running"
        COLOR="danger"
        slack_msg "$MESSAGE" "$COLOR"
        # create a lock file to only alert once
        touch "$LOCK_FILE"
      fi
      ;;
    true)
      if [ -f "$LOCK_FILE" ]; then
        MESSAGE="running"
        COLOR="good"
        slack_msg "$MESSAGE" "$COLOR"
        # remove lock file
        rm "$LOCK_FILE"
      fi
      ;;
    *)
      if [ ! -f "$LOCK_FILE" ]; then
        MESSAGE="unknown"
        COLOR="danger"
        slack_msg "$MESSAGE" "$COLOR"
        echo "$STATUS $DOCKER_STATUS"
        touch "$LOCK_FILE"
        exit 1
      fi
  esac

done
