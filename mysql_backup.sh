#!/bin/sh
USER=
PW=
DIR=/backup/mysql
DATE=$(date '+%Y%m%d%H%M%S')

echo Running: "$DATE";

mysqldump -u"$USER" -p"$PW" --databases drewwiki mysql | gzip > "$DIR"/mysql."$(hostname -s)"."$DATE".sql.gz;

# delete backups older than 30 days
# find $DIR -type f -mtime +30 -exec rm -v {} \;
