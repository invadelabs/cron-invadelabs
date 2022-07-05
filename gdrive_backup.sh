#!/bin/bash
# Drew Holt <drew@invadelabs.com>
# https://github.com/invadelabs/cron-invadelabs/blob/master/gdrive_backup.sh
#
# cron; 0 23 * * * /root/scripts/gdrive_backup.sh -a drewserv -f googledrive:/Backup/Web -l /root/scripts/gdrive_drewserv.txt -s
# cron; 0 23 * * * /root/scripts/gdrive_backup.sh -a invadelabs.com -f googledrive:/Backup/Web -l /root/scripts/gdrive_invadelabs.com.txt -s
#
# create an archive, upload it to google drive, send status to slack and/or email
#
# rclone requires https://rclone.org/ configured for googledrive
# apt install rclone / dnf install rclone
# slack requires https://github.com/course-hero/slacktee configured in path
# highlight;
# apt install highlight

usage () {
    echo "usage: $(basename "$0") -a archivename -f googledrive:/Backup/Web -l gdrive_backup_invadelabs.com.txt -e my@email.com -s"
    echo "  required:"
    echo "  -a archive       name of archive"
    echo "  -f Backup/Web    path to gdrive archive folder without leading slash"
    echo "  -l list.txt      list of files to add to archive"
    echo ""
    echo "  requires atleast one of the following:"
    echo "  -e email         email address"
    echo "  -s               use slack"
    exit 1
}

# note no : after s
while getopts a:e:f:l:s option
do
  case "${option}"
  in
  a) ARCHIVE=${OPTARG};;
  e) EMAIL_TO=${OPTARG};;
  f) DESTINATION=${OPTARG};;
  l) FILELIST=${OPTARG};;
  s) USE_SLACK="true";;
  *)
    usage
    exit 1
    ;;
  esac
done

if [ -z "$1" ]; then
  usage
fi

if [ -z "$ARCHIVE" ] || [ -z "$DESTINATION" ] || [ -z "$FILELIST" ]; then
  echo "Need an archive name, destination path, and file list. ex:"
  echo "./gdrive_backup.sh -a invadelabs.com -f googledrive:/Backup/Web -l gdrive_backup_invadelabs.com.txt"
  exit 1
elif [ -z "$EMAIL_TO" ] && [ -z "$USE_SLACK" ]; then
  echo "Need to set atleast one of -e or -s. ex:"
  echo "./gdrive_backup.sh -e my@gmail.com -s"
  exit 1
fi

DATE=$(date '+%Y%m%d%H%M%S%z')

# pack everything into a tar.xz
pack_tar () {
  tar -I "pxz -T 0" --warning=no-file-changed -cf /root/"$ARCHIVE"."$DATE".tar.xz $(cat $FILELIST)
}

# push archive and sha256sum to google drive
cloud_push () {
  rclone copy /root/"$ARCHIVE"."$DATE".tar.xz "$DESTINATION"
}

check_md5 () {
  A=$(md5sum /root/"$ARCHIVE"."$DATE".tar.xz | cut -d" " -f1)
  B=$(rclone md5sum -v "$DESTINATION"/"$ARCHIVE"."$DATE".tar.xz | cut -d" " -f1)
  if [[ "$A" == "$B" ]]; then
    echo "md5sum: $A"
  else
    echo "md5sum FAILED $A != $B"
  fi
}

# get the stats of archive on google drive
get_stat () {
  rclone lsjson -v "$DESTINATION"/"$ARCHIVE"."$DATE".tar.xz | jq -M -c '.[]';
  check_md5
}

# get url of archive on google drive
get_url () {
  rclone link  "$DESTINATION"/"$ARCHIVE"."$DATE".tar.xz
}

# creates text output as preformatted html
hl () {
  highlight --syntax txt --inline-css
}

# send email with type text/html
mailer () {
  mailx -a 'Content-Type: text/html' -s "$ARCHIVE backup $DATE" "$EMAIL_TO"
}

slack_msg () {
  echo "$1" | slacktee.sh \
  --config /root/slacktee.conf \
  -e "rclone lsjson $DESTINATION/$ARCHIVE.$DATE.tar.xz" "Command run"\
  -t "$URL" \
  -a good \
  -c backup \
  -u "$(basename "$0")" \
  -i floppy_disk \
  -l "$URL" > /dev/null;
  #-p # plain text message
}

notify_status () {
  # set to variables so we don't have to do this twice for email and slack
  URL=$(get_url)
  STATUS=$(get_stat)

  # if set email status and url of file on google drive
  if [ -n "$EMAIL_TO" ]; then
    echo "$URL $STATUS" | hl | mailer > /dev/null;
  fi

  # if set send status and url to slack
  if [ -n "$USE_SLACK" ]; then
    slack_msg "$STATUS" > /dev/null;
  fi
}

# remove archive from local disk
clean_up () {
  rm /root/"$ARCHIVE"."$DATE".tar.xz
}

pack_tar
cloud_push
notify_status
clean_up
