#!/bin/bash
# Drew Holt <drew@invadelabs.com>

USER="$(head -1 /root/check_ddns.txt)"
PASS="$(tail -1 /root/check_ddns.txt)"
IP="$(dig +short myip.opendns.com @resolver1.opendns.com)"
DDNS_HOST=parents.invadelabs.com

curl -sS "https://$USER:$PASS@domains.google.com/nic/update?hostname=$DDNS_HOST&myip=$IP" | \
  xargs echo "$(date '+%Y%m%d%H%M%S%z')" >> google_ddns.log
