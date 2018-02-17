#!/bin/sh
# mysql_backup.sh
# Drew Holt <drewderivative@gmail.com>
# Simple mysql backup script

USER=
PW=
DIR=/backup/mysql
DATE=$(date '+%Y%m%d%H%M%S')

echo Running: "$DATE";

# dump databases drewwiki and mysql
dump_sql () {
  mysqldump -u"$USER" -p"$PW" --databases drewwiki mysql
}

# create xz archive with hostname and date run
create_archive () {
  xz > "$DIR"/mysql."$(hostname -s)"."$DATE".sql.xz
}

# put it together
dump_sql | create_archive

# delete backups older than 30 days
# find $DIR -type f -mtime +30 -exec rm -v {} \;
