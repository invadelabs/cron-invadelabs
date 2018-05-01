# shellcheck disable=SC2035,SC2148
# SC2035: Use ./*glob* or -- *glob* so names with dashes won't become options.
# SC2148: Tips depend on target shell and yours is unknown. Add a shebang.

# m h  dom mon dow   command
0 3,15 * * * certbot --apache renew --quiet
0 5 * * * /root/scripts/gen_sitemap.sh -s
1 5 * * * /root/scripts/gdrive_backup.sh -a invadelabs.com -d /snap/bin -f Backup/Web -l gdrive_backup_invadelabs.com.txt -s
0 * * * * hostname invadelabs.com
59 4 * * 0 /usr/sbin/lynis audit system | /root/ansi2html.sh --bg=dark | mailx -a 'Content-Type: text/html' -s "Lynis Audit: invadelabs.com" drew@invadelabs.com
