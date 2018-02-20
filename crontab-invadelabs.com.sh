# shellcheck disable=SC2035,SC2148
# SC2035: Use ./*glob* or -- *glob* so names with dashes won't become options.
# SC2148: Tips depend on target shell and yours is unknown. Add a shebang.

# m h  dom mon dow   command
0 3,15 * * * certbot --apache renew --quiet
0 6 * * * /root/gen_sitemap.sh
0 6 * * * /root/gdrive_backup.sh invadelabs.com Backup/Web
0 * * * * hostname invadelabs.com
