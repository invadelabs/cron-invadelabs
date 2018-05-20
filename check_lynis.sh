#!/bin/bash
# Drew Holt <drew@invadelabs.com>

run_lynis () {
  lynis audit system
}

format_ansi2html () {
  if [ ! -f /root/scripts/ansi2html.sh ]; then
    curl  -sS -o /root/scripts/ansi2html.sh https://raw.githubusercontent.com/pixelb/scripts/master/scripts/ansi2html.sh
    chmod 755 /root/scripts/ansi2html.sh
  fi

  /root/scripts/ansi2html.sh --bg=dark
}

mail_it () {
  mailx -a 'Content-Type: text/html' -s "Lynis Audit: $HOSTNAME" drew@invadelabs.com
}

run_lynis | format_ansi2html | mail_it
