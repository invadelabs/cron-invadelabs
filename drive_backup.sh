#!/bin/bash

DATE=$(date '+%Y%m%d%H%M%S')

function backup () {
  php /var/www/drew.invadelabs.com/maintenance/sqlite.php -q --backup-to /root/drew_wiki."$DATE".sqlite

  tar -cJf /root/invadelabs.com."$DATE".tar.xz \
    -C /etc apache2/ \
    -C /etc letsencrypt/ \
    -C /var/www/drew.invadelabs.com LocalSettings.php \
    -C /root drew_wiki."$DATE".sqlite

  /snap/bin/drive push -no-prompt -destination /Backup/Web invadelabs.com."$DATE".tar.xz >/dev/null

  rm /root/invadelabs.com."$DATE".tar.xz /root/drew_wiki."$DATE".sqlite
}

function get_stat () {
  /snap/bin/drive stat Backup/Web/invadelabs.com."$DATE".tar.xz | sed 's/\x1b\[[0-9;]*m//g'
}

function get_url () {
  /snap/bin/drive url Backup/Web/invadelabs.com."$DATE".tar.xz | cut -d" " -f 2
}

function hl () {
  highlight --syntax bash --inline-css
}

function mailer () {
  mailx -a 'Content-Type: text/html' -s "invadelabs.com backup $DATE" drewderivative@gmail.com
}

# backup file to google drive
backup;

URL=$(get_url)
STATUS=$(get_stat)

# email status and url of file on google drive
echo "$URL $STATUS" | hl | mailer > /dev/null;

# if slacktee.sh exists send status and url of file on google drive
echo "$STATUS" | ./slacktee.sh --config slacktee.conf -l $URL > /dev/null;
