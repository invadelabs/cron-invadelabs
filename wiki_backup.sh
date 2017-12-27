#!/bin/sh
DIR=/mnt/raid5/drew/backup/wiki
DATE=`date +%F.%T`

echo Running: `date`;

mkdir -vp $DIR;

php /var/www/html/drewwiki/maintenance/sqlite.php --backup-to $DIR/drewwiki.$DATE.sqlite;
xz $DIR/drewwiki.$DATE.sqlite

# delete backups older than 30 days
#find $DIR -type f -mtime +30 -exec rm -v {} \;
