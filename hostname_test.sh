#!/bin/bash
# not for cron but check how often google cloud resets hostname
# $nohup /home/drew/hostname_test.sh

while true; 
  do 
  if [ $(hostname -f) == "invadelabs.com" ]; then
    echo $(date) $(hostname) >> /home/drew/hostname_test
    sleep 1 
  else 
    echo $(date) $(hostname) >> /home/drew/hostname_test
    break
  fi 
done
