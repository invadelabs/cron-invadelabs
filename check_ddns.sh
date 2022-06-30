#!/bin/bash
# Drew Holt <drew@invadelabs.com>
# https://github.com/invadelabs/cron-invadelabs/blob/master/check_ddns.sh
# cron; */5 * * * * /root/scripts/check_ddns.sh nm.invadelabs.com
#
# shellcheck disable=SC2206
# SC2206: Quote to prevent word splitting/globbing, or split robustly with mapfile or read -a.
#
# Script to update google domains ddns with netrc credentials file
# then update google cloud firewall rule

# DDNS_HOST=nm.invadelabs.com
DDNS_HOST="$1"

usage () {
  echo "${0} - update Google Domains DDNS"
  echo "e.x.: $0 nm.invadelabs.com"
}

if [ -z "$1" ]; then
  usage
  exit 1
fi

valid_ip () {
  local  ip=$1
  local  stat=1

  if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    OIFS=$IFS
    IFS='.'
    ip=($ip)
    IFS=$OIFS
    [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
      && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
    stat=$?
  fi
  return $stat
}

IP="$(dig +short myip.opendns.com @resolver1.opendns.com 2>/dev/null || true)"
DDNS_IP="$(dig +short @resolver1.opendns.com "$DDNS_HOST" 2>/dev/null || true)"
DATE="$(date '+%Y-%m-%d-%H:%M:%S%z')"

slack_msg () {
  echo "$1" | slacktee.sh \
  --config /root/slacktee.conf \
  -a warning \
  -c general \
  -u "$(basename "$0")" \
  -i ipv4 \
  -t "$DDNS_HOST at $IP" > /dev/null;
  # -e "docker ps -a" "$DOCKER_STATUS "\
  # -t "Container $CONTAINER is $1 on $HOSTNAME" \
  # -p \
}

if [ ! "$IP" == "$DDNS_IP" ] && valid_ip "$IP"; then
  # update google domains ddns
  #CURL="$(curl --netrc-file /root/check_ddns.cred -sS "https://domains.google.com/nic/update?hostname=$DDNS_HOST&myip=$IP")"

  # update cloudflare dns
  USER=$(jq -r .username < /root/cloudflare_ddns.cred)
  API_KEY=$(jq -r .api_key < /root/cloudflare_ddns.cred)
  cloudflare-ddns "$USER" "$API_KEY" "$DDNS_HOST"

  # update gcp firewall rule
  gcloud compute firewall-rules update allow-drew-nm1 --source-ranges "$IP"/32

  ssh -i /home/drew/.ssh/tunnel_2020.05.17 drew@srv.invadelabs.com "echo $IP > /home/drew/home_ip"

  slack_msg "$( echo -e "${DDNS_HOST} IP Updated: \nDate Run: ${DATE} \nNew IP: $IP \nOld IP: $DDNS_IP")"
elif [ "$IP" == "$DDNS_IP" ]; then
  exit 0
elif [ -z "$IP" ]; then
  # if we end up here the link or dns is down
  exit 0
else
  slack_msg "$( echo -e "Something went wrong. \nDate: ${DATE} \nIP: $IP \nDDNS IP: $DDNS_IP \nDDNS Host: $DDNS_HOST")"
fi

# https://user:pass@domains.google.com/nic/update?hostname=$DDNS_HOST&myip=$IP
