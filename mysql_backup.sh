#!/bin/sh
USER=
PW=
DIR=/mnt/raid5/drew/backup/mysql

echo Running: "$(date '+%Y%m%d%H%M%S')";

mkdir -vp $DIR;

mysqldump -u"$USER" -p"$PW" --databases drewwiki mysql | gzip > "$DIR"/mysql."$(hostname -s)"."$(date '+%Y%m%d%H%M%S')".sql.gz;
#mysqldump -u$USER -p$PW --all-databases | gzip > $DIR/mysql.`hostname -s`.`date +%F.%T`.sql.gz;

# delete backups older than 30 days
#find $DIR -type f -mtime +30 -exec rm -v {} \;
