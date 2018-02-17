#!/bin/bash
# Drew Holt <drewderivative@gmail.com>
# gdrive_backup.sh
# create an archive, upload it to google drive, send status to slack and email

DATE=$(date '+%Y%m%d%H%M%S')

# pack everything into a tar.xz and push it to google drive
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

# get the status of archive on google drive
function get_stat () {
  /snap/bin/drive stat Backup/Web/invadelabs.com."$DATE".tar.xz | sed 's/\x1b\[[0-9;]*m//g'
}

# get url of archive on google drive
function get_url () {
  /snap/bin/drive url Backup/Web/invadelabs.com."$DATE".tar.xz | cut -d" " -f 2
}

# creates text output as preformatted html
function hl () {
  highlight --syntax txt --inline-css
}

# send email with type text/html
function mailer () {
  mailx -a 'Content-Type: text/html' -s "invadelabs.com backup $DATE" drewderivative@gmail.com
}

# start backup
backup;

# set to variables so we don't have to do this twice for email and slack
URL=$(get_url)
STATUS=$(get_stat)

# email status and url of file on google drive
echo "$URL $STATUS" | hl | mailer > /dev/null;

# send status and url to slack
echo "$STATUS" | ./slacktee.sh --config slacktee.conf -l "$URL" > /dev/null;
