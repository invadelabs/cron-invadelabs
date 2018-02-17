# shellcheck disable=SC2035,SC2046,SC2086,SC2148
# SC2035: Use ./*glob* or -- *glob* so names with dashes won't become options.
# SC2046: Quote this to prevent word splitting.
# SC2086: Double quote to prevent globbing and word splitting.
# SC2148: Tips depend on target shell and yours is unknown. Add a shebang.

# m h  dom mon dow   command
0 3,15 * * * certbot --apache renew --quiet
0 6 * * * S=drew.invadelabs.com; D=/var/www/$S/sitemap; mv $D/sitemap-$S-NS_0-0.xml $D/sitemap-$S-NS_0-0.$(date '+\%Y\%m\%d\%H\%M\%S').xml; php /var/www/$S/maintenance/generateSitemap.php --compress no --fspath=/var/www/$S/sitemap/ --identifier=$S --urlpath=https://$S/ --server=https://$S | mailx -a 'Content-Type: text/html' -s "DrewWiki Sitemap Updated $DATE" drewderivative@gmail.com
0 6 * * * /root/gdrive_backup.sh
0 * * * * hostname invadelabs.com
