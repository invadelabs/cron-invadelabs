#!/bin/bash
# shellcheck disable=SC1117
# SC1117: Backslash is literal in "\n". Prefer explicit escaping: "\\n".
# Drew Holt <drewderivative@gmail.com>
# convert mediawiki to md and git commit on cron
# 
# apt-get install pandoc bc
# git clone https://github.com/peterjc/mediawiki_to_git_md
# add key to ~/.ssh/my-github-key
# chmod 400 ~/.ssh/my-github-key
# usage: ./wiki_to_md.sh &> /dev/null

SITE="drew.invadelabs.com"
DIR="/var/www/$SITE"

DATE=$(date '+%Y%m%d%H%M%S')

export GIT_SSH_COMMAND='ssh -i ~/.ssh/jenkins-invadelabs -o StrictHostKeyChecking=no'

function mkdir_git () {
  mkdir /root/"$SITE"."$DATE"
  touch /root/"$SITE"."$DATE"/user_blocklist.txt
  echo "Drew	Drew Holt <drewderivative@gmail.com>" > /root/"$SITE"."$DATE"/usernames.txt
  IGNORE="$(cat <<EOF
*.sql
*.xml
EOF
)"
  echo "$IGNORE" > /root/"$SITE"."$DATE"/.gitignore
}

function export_xml () {
  php "$DIR"/maintenance/dumpBackup.php \
    --quiet \
    --conf "$DIR"/LocalSettings.php \
    --full \
    --include-files \
    --uploads > /root/"$SITE"."$DATE"/drewwiki.xml
}

function git_init_dir () {
  git -C /root/"$SITE"."$DATE" init
  git -C /root/"$SITE"."$DATE" add --all
  git -C /root/"$SITE"."$DATE" commit -m "initial commit"
}

function mediawiki_to_git_md () {
  cd /root/"$SITE"."$DATE" || exit
  /root/mediawiki_to_git_md/convert.py /root/"$SITE"."$DATE"/drewwiki.xml
}

function git_reduce_size () {
  git -C /root/"$SITE"."$DATE" gc
  git -C /root/"$SITE"."$DATE" gc --aggressive
  git -C /root/"$SITE"."$DATE" prune
}

function git_push () {
  git -C /root/"$SITE"."$DATE" remote add origin git@github.com:invadelabs/drewwiki.git
  git -C /root/"$SITE"."$DATE" push --set-upstream origin master -f
}

function cleanup () {
  if [ -d /root/"$SITE"."$DATE" ]; then
    cd /root || exit
    rm -rf "$SITE"."$DATE"
  fi
}

START=$(date +%s)

mkdir_git
export_xml
git_init_dir &> /dev/null
mediawiki_to_git_md &> /dev/null
git_reduce_size &> /dev/null
STATUS=$(git_push)

END=$(date +%s)
DIFF=$(echo "$END - $START" | bc)

echo -e "$DIFF seconds\n$STATUS" | /root/slacktee.sh --config /root/slacktee.conf -u "$(basename "$0")" -i floppy_disk -l "$URL" > /dev/null;

cleanup
