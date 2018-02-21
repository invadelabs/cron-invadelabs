#!/bin/bash
# shellcheck disable=SC1117
# SC1117: Backslash is literal in "\n". Prefer explicit escaping: "\\n".
# Drew Holt <drewderivative@gmail.com>
# gen_sitemap.sh
# create a new sitemap of media wiki on cron

SITE="drew.invadelabs.com"
DIR="/var/www/$SITE/sitemap"
DATE=$(date '+%Y%m%d%H%M%S')
URL="https://$SITE/sitemap/sitemap-$SITE-NS_0-0.xml"
URL_OLD="https://$SITE/sitemap/sitemap-$SITE-NS_0-0.$DATE.xml"

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
function mailer () {
  mailx -a 'Content-Type: text/html' -s "DrewWiki Sitemap Updated $DATE" drewderivative@gmail.com
}

# creates text output as preformatted html
function hl () {
  highlight --syntax txt --inline-css
}

# send the email
echo -e "$URL\n$URL_OLD\n$NEWSITE" | hl | mailer > /dev/null

# send the slack message
echo -e "$URL_OLD\n$NEWSITE" | ./slacktee.sh --config slacktee.conf -u "$(basename "$0")" -i world_map -l "$URL" > /dev/null;
