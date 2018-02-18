# shellcheck disable=SC2035,SC2046,SC2148,SC2211
# SC2035: Use ./*glob* or -- *glob* so names with dashes won't become options.
# SC2046: Quote this to prevent word splitting.
# SC2148: Tips depend on target shell and yours is unknown. Add a shebang.
# SC2211: This is a glob used as a command name. Was it supposed to be in ${..}, array, or is it missing quoting?

# m h  dom mon dow   command
*/5 * * * * IP=$( dig +short myip.opendns.com @resolver1.opendns.com ) && curl -sS "https://some_generated_user:some_generated_password@domains.google.com/nic/update?hostname=ddns-host.invadelabs.com&myip=$IP" | xargs echo $(date '+\%Y\%m\%d\%H\%M\%S') >> google_ddns.log
