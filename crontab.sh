# shellcheck disable=SC2035,SC2046,SC2086,SC2148
# SC2035: Use ./*glob* or -- *glob* so names with dashes won't become options.
# SC2046: Quote this to prevent word splitting.
# SC2086: Double quote to prevent globbing and word splitting.
# SC2148: Tips depend on target shell and yours is unknown. Add a shebang.

0 3,15 * * * certbot renew --quiet
0 6 * * * DIR=/var/www/drew.invadelabs.com/sitemap; mv $DIR/sitemap-drew.invadelabs.com-NS_0-0.xml $DIR/sitemap-drew.invadelabs.com-NS_0-0.$(date '+\%Y\%m\%d\%H\%M\%S').xml; php /var/www/drew.invadelabs.com/maintenance/generateSitemap.php --compress no --fspath=/var/www/drew.invadelabs.com/sitemap/ --identifier=drew.invadelabs.com --urlpath=https://drew.invadelabs.com/ --server=https://drew.invadelabs.com > /dev/null
18 8 * * * DATE=$(date '+\%Y\%m\%d\%H\%M\%S'); php /var/www/drew.invadelabs.com/maintenance/sqlite.php -q --backup-to /tmp/drew_wiki."$DATE".sqlite; tar -cJf /tmp/invadelabs.com.$DATE.tar.xz -C /etc apache2/ -C /etc letsencrypt/ -C /tmp drew_wiki."$DATE".sqlite; echo "invadelabs.com backup $DATE" | mailx -A /tmp/invadelabs.com.$DATE.tar.xz -s "invadelabs.com backup $DATE" drewderivative@gmail.com; rm /tmp/invadelabs.com."$DATE".tar.xz /tmp/drew_wiki."$DATE".sqlite
* 1,7,13,19 * * * hostname invadelabs.com
