#!/bin/bash
# shellcheck disable=SC1117
# SC1117: Backslash is literal in "\n". Prefer explicit escaping: "\\n".
# Drew Holt <drewderivative@gmail.com>
# gen_sitemap.sh
# create a new sitemap of media wiki on cron
# slack requires https://github.com/course-hero/slacktee configured in path

SITE="drew.invadelabs.com"
DIR="/var/www/$SITE/sitemap"
DATE=$(date '+%Y%m%d%H%M%S')
URL="https://$SITE/sitemap/sitemap-$SITE-NS_0-0.xml"
URL_OLD="https://$SITE/sitemap/sitemap-$SITE-NS_0-0.$DATE.xml"

usage () {
    echo "  requires atleast one of the following:"
    echo "  -e email         email address"
    echo "  -s               use slack"
    exit 1
}

if [ "$1" == "" ]; then
  usage
fi

# note no : after s
while getopts e:s option
do
  case "${option}"
  in
  e) EMAIL_TO=${OPTARG};;
  s) USE_SLACK="true";;
  *)
    usage
    exit 1
    ;;
  esac
done

# archive old sitemap.xml
mv $DIR/sitemap-"$SITE"-NS_0-0.xml $DIR/sitemap-"$SITE"-NS_0-0."$DATE".xml
xz $DIR/sitemap-"$SITE"-NS_0-0."$DATE".xml

# generate new sitemap
NEWSITE=$(php /var/www/"$SITE"/maintenance/generateSitemap.php \
  --compress no \
  --fspath=/var/www/"$SITE"/sitemap/ \
  --identifier="$SITE" \
  --urlpath=https://"$SITE"/ \
  --server=https://"$SITE")

# send an email
mailer () {
  mailx -a 'Content-Type: text/html' -s "DrewWiki Sitemap Updated $DATE" "$EMAIL_TO"
}

# creates text output as preformatted html
hl () {
  highlight --syntax txt --inline-css
}

# if set send the email
if [ ! -z "$EMAIL_TO" ]; then
  echo -e "$URL\n$URL_OLD\n$NEWSITE" | hl | mailer > /dev/null
fi

# if set send the slack message
if [ ! -z "$USE_SLACK" ]; then
  echo -e "$URL_OLD\n$NEWSITE" | ./slacktee.sh --config slacktee.conf -u "$(basename "$0")" -i world_map -l "$URL" > /dev/null;
fi
