#!/bin/bash
# Drew Holt <drew@invadelabs.com>

run_lynis () {
  /usr/sbin/lynis audit system
}

format_ansi2html () {
  if [ ! -f /root/scripts/ansi2html.sh ]; then
    curl  -sS -O /root/scripts/ansi2html.sh https://raw.githubusercontent.com/pixelb/scripts/master/scripts/ansi2html.sh
    chmod 755 /root/scripts/ansi2html.sh
  fi

  /root/ansi2html.sh --bg=dark
}

mail_it () {
  mailx -a 'Content-Type: text/html' -s "Lynis Audit: invadelabs.com" drew@invadelabs.com
}

run_lynis | format_ansi2html | mail_it
