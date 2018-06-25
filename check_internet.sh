#!/bin/bash
# Drew Holt <drew@invadelabs.com>
# https://github.com/invadelabs/cron-invadelabs/blob/master/check_ddns.sh
# cron; */5 * * * * /root/scripts/check_internet.sh
#
# use LTE modem if ETH gateway is down

ETH_DEV="enp1s0"
ETH_GATEWAY="192.168.1.1"

LTE_DEV="enp0s26u1u1c4i2"
LTE_GATEWAY="172.20.10.1"

LOCK_FILE="/tmp/${ETH_DEV}_down"
CHECK_HOST="8.8.8.8"

lte_up () {
  ip route add default via "$LTE_GATEWAY" dev "$LTE_DEV" metric 10
  mv /etc/resolv.conf /etc/resolv.conf.orig
    echo "nameserver 8.8.8.8" > /etc/resolv.conf
}

lte_down () {
  ip route del default via "$ETH_GATEWAY" dev "$ETH_DEV" metric 10
  mv -f /etc/resolv.conf.orig /etc/resolv.conf
}

format_ansi2html () {
  if [ ! -f /root/scripts/ansi2html.sh ]; then
    curl  -sS -o /root/scripts/ansi2html.sh https://raw.githubusercontent.com/pixelb/scripts/master/scripts/ansi2html.sh
    chmod 755 /root/scripts/ansi2html.sh
  fi

  /root/scripts/ansi2html.sh --bg=dark
}

mail_it () {
  ip r; ip a | format_ansi2html | mailx -s "$(echo -e "Internet Status $1\nContent-Type: text/html")" "$2"
}

gateway_state () {
  if ! ping -c 4 "$CHECK_HOST" -W 1 -I "$ETH_DEV" >/dev/null; then
    if [ ! -f "$LOCK_FILE" ]; then
      touch "$LOCK_FILE"
      lte_up
      mail_it DOWN drew@invadelabs.com
    fi
  else
    if [ -f $LOCK_FILE ]; then
      rm "$LOCK_FILE"
      lte_down
      mail_it UP drew@invadelabs.com
    fi
  fi
}

gateway_state
