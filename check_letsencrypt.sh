#!/bin/bash
# Drew Holt <drew@invadelabs.com>
# cron; 15 23 * * * /root/scripts/check_letsencrypt.sh
#
# check and update if wildcard cert has updated
#
# requires rclone

get_latest () {
  LATEST="$(rclone ls googledrive:/Backup/Web 2>&1 | awk -F" " '{ print $2 }' | grep -E '^invadelabs.com.*.tar.xz$' | sort | tail -n 1)"
  rclone copyto googledrive:/Backup/Web/"$LATEST" /tmp/"$LATEST"
}

compare_tar () {
  tar --compare --file=/tmp/"$LATEST" -C /etc --exclude LocalSettings.php --exclude drew_wiki.sqlite
}

extract_latest () {
  tar -C /etc -Jxvf /tmp/"$LATEST" letsencrypt/
}

clean_up () {
  rm /tmp/"$LATEST"
}

get_latest

if ! compare_tar; then
  extract_latest
  systemctl reload httpd
fi

clean_up
