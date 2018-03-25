#!/bin/bash
# Drew Holt <drewderivative@gmail.com>
# create an archive, upload it to google drive, send status to slack and email
# requires https://github.com/odeke-em/drive initialized in cwd
# slack requires https://github.com/course-hero/slacktee configured in path

# ARCHIVE="invadelabs.com"
# DRIVE_BIN_PATH="/snap/bin"
# EMAIL_TO="drewderivative@gmail.com"
# GDRIVE_FOLDER="Backup/Web" # no leading slash

usage () {
    echo "usage: $(basename "$0") -a archivename -d /snap/bin -f Backup/Web -l gdrive_backup_invadelabs.com.txt -e my@email.com -s"
    echo "  required:"
    echo "  -a archive       name of archive"
    echo "  -d /snap/bin     path to drive binary"
    echo "  -f Backup/Web    path to gdrive archive folder without leading slash"
    echo "  -l list.txt      list of files to add to archive"
    echo ""
    echo "  requires atleast one of the following:"
    echo "  -e email         email address"
    echo "  -s               use slack"
    exit 1
}

if [ "$1" == "" ]; then
  usage
fi

# note no : after s
while getopts a:d:e:f:l:s option
do
  case "${option}"
  in
  a) ARCHIVE=${OPTARG};;
  d) DRIVE_BIN_PATH=${OPTARG};;
  e) EMAIL_TO=${OPTARG};;
  f) GDRIVE_FOLDER=${OPTARG};;
  l) FILELIST=${OPTARG};;
  s) USE_SLACK="true";;
  *)
    usage
    exit 1
    ;;
  esac
done

if [ -z "$ARCHIVE" ] || [ -z "$DRIVE_BIN_PATH" ] || [ -z "$GDRIVE_FOLDER" ] || [ -z "$FILELIST" ]; then
  echo "Need an archive name, path to drive binary, destination path, and file list. ex:"
  echo "./gdrive_backup.sh -a invadelabs.com -d /snap/bin -f Backup/Web -l gdrive_backup_invadelabs.com.txt"
  exit 1
elif [ -z "$EMAIL_TO" ] && [ -z "$USE_SLACK" ]; then
  echo "Need to set atleast one of -e or -s. ex:"
  echo "./gdrive_backup.sh -e my@gmail.com -s"
  exit 1
fi

DATE=$(date '+%Y%m%d%H%M%S')

# pack everything into a tar.xz
backup () {
  tar -cJf /root/"$ARCHIVE"."$DATE".tar.xz -T "$FILELIST"
}

# push archive to google drive,
google_push () {
  "$DRIVE_BIN_PATH"/drive push -no-prompt -destination /"$GDRIVE_FOLDER" "$ARCHIVE"."$DATE".tar.xz >/dev/null
}

# remove archive from local disk
clean_up () {
  # rm /root/"$ARCHIVE"."$DATE".tar.xz /root/drew_wiki."$DATE".sqlite
  rm /root/"$ARCHIVE"."$DATE".tar.xz
}

# get the status of archive on google drive and strip out ansi colors
get_stat () {
  "$DRIVE_BIN_PATH"/drive stat "$GDRIVE_FOLDER"/"$ARCHIVE"."$DATE".tar.xz | sed 's/\x1b\[[0-9;]*m//g'
}

# get url of archive on google drive
get_url () {
  "$DRIVE_BIN_PATH"/drive url "$GDRIVE_FOLDER"/"$ARCHIVE"."$DATE".tar.xz | cut -d" " -f 2
}

# creates text output as preformatted html
hl () {
  highlight --syntax txt --inline-css
}

# send email with type text/html
mailer () {
  mailx -a 'Content-Type: text/html' -s "$ARCHIVE backup $DATE" "$EMAIL_TO"
}

# start backup
backup; google_push; clean_up;

# set to variables so we don't have to do this twice for email and slack
URL=$(get_url)
STATUS=$(get_stat)

# if set email status and url of file on google drive
if [ ! -z "$EMAIL_TO" ]; then
  echo "$URL $STATUS" | hl | mailer > /dev/null;
fi

# if set send status and url to slack
if [ ! -z "$USE_SLACK" ]; then
  echo "$STATUS" | ./slacktee.sh --config slacktee.conf -u "$(basename "$0")" -i floppy_disk -l "$URL" > /dev/null;
fi
