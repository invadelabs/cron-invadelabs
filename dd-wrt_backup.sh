#!/bin/sh

IP_ADDR="192.168.1.1"
USER=""
PASS=""

LOGFILE="/home/drew/cron/dd-wrt_backup.log"
CFEFILE="/mnt/raid5/drew/backup/dd-wrt/cfe.bin-$(date '+%Y%m%d%H%M%S')";
NVRAMBAKFILE="/mnt/raid5/drew/backup/dd-wrt/nvrambak.bin-$(date '+%Y%m%d%H%M%S')";

wget -a $LOGFILE --user=$USER --password=$PASS \
	http://$IP_ADDR/backup/cfe.bin -O "$CFEFILE";
gzip "$CFEFILE";

wget -a $LOGFILE --user=$USER --password=$PASS \
	http://$IP_ADDR/nvrambak.bin -O "$NVRAMBAKFILE";
gzip "$NVRAMBAKFILE";

wget -a $LOGFILE --user=$USER --password=$PASS \
	http://$IP_ADDR/traffdata.bak -O- | gzip > \
/mnt/raid5/drew/backup/dd-wrt/traffdata.bak."$(date '+%Y%m%d%H%M%S')".gz;
