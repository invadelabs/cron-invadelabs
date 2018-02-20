#!/bin/bash
# Drew Holt <drewderivative@gmail.com>
# create an archive, upload it to google drive, send status to slack and email
# requires https://github.com/odeke-em/drive initialized in cwd
# requires https://github.com/course-hero/slacktee in path
#
# usage: gdrive_backup.sh archivename gdrive_dest_dir
# ex: ./gdrive_backup.sh invadelabs.com Backup/Web

DATE=$(date '+%Y%m%d%H%M%S')
EMAIL_TO="drewderivative@gmail.com"
# ARCHIVE="invadelabs.com"
ARCHIVE="$1"
# GDRIVE_FOLDER="Backup/Web" # no leading slash
GDRIVE_FOLDER="$2"
DRIVE_BIN_PATH="/snap/bin"

if [ -z "$ARCHIVE" ] || [ -z "$GDRIVE_FOLDER" ]; then
  echo "Need an archive name and destination path, ex:"
  echo "./gdrive_backup.sh invadelabs.com Backup/Web"
  exit 1
fi

# pack everything into a tar.xz, push it to google drive, cleanup
function backup () {
  tar -cJf /root/"$ARCHIVE"."$DATE".tar.xz \
    -C /etc apache2/ \
    -C /etc letsencrypt/ \
    -C /var/www/drew.invadelabs.com LocalSettings.php \
    -C /var/www/data drew_wiki.sqlite
}

function google_push {
  "$DRIVE_BIN_PATH"/drive push -no-prompt -destination /"$GDRIVE_FOLDER" "$ARCHIVE"."$DATE".tar.xz >/dev/null
}

function clean_up {
  # rm /root/"$ARCHIVE"."$DATE".tar.xz /root/drew_wiki."$DATE".sqlite
  rm /root/"$ARCHIVE"."$DATE".tar.xz
}

# get the status of archive on google drive and strip out ansi colors
function get_stat () {
  "$DRIVE_BIN_PATH"/drive stat "$GDRIVE_FOLDER"/"$ARCHIVE"."$DATE".tar.xz | sed 's/\x1b\[[0-9;]*m//g'
}

# get url of archive on google drive
function get_url () {
  "$DRIVE_BIN_PATH"/drive url "$GDRIVE_FOLDER"/"$ARCHIVE"."$DATE".tar.xz | cut -d" " -f 2
}

# creates text output as preformatted html
function hl () {
  highlight --syntax txt --inline-css
}

# send email with type text/html
function mailer () {
  mailx -a 'Content-Type: text/html' -s "$ARCHIVE backup $DATE" "$EMAIL_TO"
}

# start backup
backup; google_push; clean_up;

# set to variables so we don't have to do this twice for email and slack
URL=$(get_url)
STATUS=$(get_stat)

# email status and url of file on google drive
echo "$URL $STATUS" | hl | mailer > /dev/null;

# send status and url to slack
echo "$STATUS" | ./slacktee.sh --config slacktee.conf -u "$(basename "$0")" -i floppy_disk -l "$URL" > /dev/null;
