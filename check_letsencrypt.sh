#!/bin/bash
# Drew Holt <drew@invadelabs.com>
# cron; 15 23 * * * /root/scripts/check_letsencrypt.sh
#
# check and update if wildcard cert has updated

DRIVE_BIN="/snap/bin"

get_latest () {
  LATEST="$($DRIVE_BIN/drive ls Backup/Web | grep invadelabs.com | grep -v sha256 | sort | tail -n 1 | cut -c 2-)"
  INV_ARCHIVE="$( echo "$LATEST" | sed 's/Backup\/Web\///' )"
  "$DRIVE_BIN"/drive pull -piped "$LATEST" > /tmp/"$INV_ARCHIVE"
}

compare_tar () {
  tar --compare --file=/tmp/"$INV_ARCHIVE" -C /etc --exclude LocalSettings.php --exclude drew_wiki.sqlite
}

extract_latest () {
  tar -C /etc -Jxvf /tmp/"$INV_ARCHIVE" letsencrypt/
}

clean_up () {
  rm /tmp/"$INV_ARCHIVE"
}

get_latest

if ! compare_tar; then
  extract_latest
  systemctl reload apache
fi

clean_up
