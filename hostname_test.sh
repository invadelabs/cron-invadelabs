#!/bin/bash
# not for cron but check how often google cloud resets hostname
# nohup hostname_test.sh

HOST_CHECK="invadelabs.com"
DATE=$(date '+%Y%m%d%H%M%S%z')
CHECK_FILE="/tmp/hostname_test-$DATE.log"

while true;
  do
  if [ "$(hostname -f)" == "$HOST_CHECK" ]; then
    echo "$(date)" "$(hostname)" >> "$CHECK_FILE"
    sleep 1
  else
    echo "$(date)" "$(hostname)" >> "$CHECK_FILE"
    break
  fi
done
