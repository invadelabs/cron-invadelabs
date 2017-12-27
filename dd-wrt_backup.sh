#!/bin/sh

ip="192.168.1.1"
user=""
pass=""

logfile="/home/drew/cron/dd-wrt_backup.log"
cfefile="/mnt/raid5/drew/backup/dd-wrt/cfe.bin-`date +%F.%T`"; 
nvrambakfile="/mnt/raid5/drew/backup/dd-wrt/nvrambak.bin-`date +%F.%T`"; 

wget -a $logfile --user=$user --password=$pass \
	http://$ip/backup/cfe.bin -O $cfefile; 
gzip $cfefile;

wget -a $logfile --user=$user --password=$pass \
	http://$ip/nvrambak.bin -O $nvrambakfile;
gzip $nvrambakfile;

wget -a $logfile --user=$user --password=$pass \
	http://$ip/traffdata.bak -O- | gzip > \
/mnt/raid5/drew/backup/dd-wrt/traffdata.bak.`date +%F.%T`.gz;
