# shellcheck disable=SC2035,SC2046,SC2148,SC2211
# SC2035: Use ./*glob* or -- *glob* so names with dashes won't become options.
# SC2046: Quote this to prevent word splitting.
# SC2148: Tips depend on target shell and yours is unknown. Add a shebang.
# SC2211: This is a glob used as a command name. Was it supposed to be in ${..}, array, or is it missing quoting?

# m h  dom mon dow   command
*/5 * * * * /root/scripts/check_ddns.sh
0 6 * * * /root/scripts/gdrive_backup.sh -a nagios-drewserv -d /var/lib/snapd/snap/bin -f Backup/Web -l gdrive_backup_nagios-drewserv.txt -s
*/1 * * * * /root/scripts/check_docker.sh
