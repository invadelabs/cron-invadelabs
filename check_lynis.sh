#!/bin/bash
# Drew Holt <drew@invadelabs.com>
# https://github.com/invadelabs/cron-invadelabs/blob/master/check_lynis.sh
#
# cron; 59 4 * * 6 /root/scripts/check_lynis.sh drew@invadelabs.com
#
# Script to email lynis system audit
# needs ansi2html.sh in $PATH http://github.com/pixelb/scripts/commits/master/scripts/ansi2html.sh

PATH="/usr/sbin:$PATH"
EMAIL_TO="$1"

if [ -z "$EMAIL_TO" ]; then
  echo "Need an email address. ex:"
  echo "./gdrive_backup.sh my@gmail.com"
  exit 1
fi

run_lynis () {
  lynis audit system
}

format_ansi2html () {
  ansi2html.sh --bg=dark
}

mail_it () {
  case "$(lsb_release -i -s)" in
    Ubuntu|Debian|Raspbian)
      mailx -a 'Content-Type: text/html' -s "Lynis Audit: $HOSTNAME" "$1"
      ;;
    Fedora)
      mailx -s "$(echo -e "Lynis Audit: $HOSTNAME\nContent-Type: text/html")" "$1"
  esac
}

run_lynis | format_ansi2html | mail_it "$EMAIL_TO"
