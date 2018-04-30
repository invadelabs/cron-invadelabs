#!/bin/sh
# Drew Holt <drew@invadelabs.com>
# script to backup cfe.bin nvrambak.bin and traffdata.bak for DD-WRT

IP_ADDR="192.168.1.1"
USER=""
PASS=""
DATE=$(date '+%Y%m%d%H%M%S%z')
DIR="/backup/dd-wrt"
LOGFILE="$DIR/dd-wrt_backup.log"
CFEFILE="$DIR/cfe.bin-$DATE";
NVRAMBAKFILE="$DIR/nvrambak.bin-$DATE";
TRAFFDATA="$DIR/traffdata.bak-$DATE";

wget -a $LOGFILE --user=$USER --password=$PASS \
	http://$IP_ADDR/backup/cfe.bin -O "$CFEFILE" \
	http://$IP_ADDR/nvrambak.bin -O "$NVRAMBAKFILE" \
	http://$IP_ADDR/traffdata.bak -O "$TRAFFDATA";

tar -cJvf $DIR/dd-wrt-"$DATE".tar.xz "$CFEFILE $TRAFFDATA $NVRAMBAKFILE";
rm "$CFEFILE $TRAFFDATA $NVRAMBAKFILE";
