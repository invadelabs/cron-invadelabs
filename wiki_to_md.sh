#!/bin/bash
# Drew Holt <drew@invadelabs.com>
# convert mediawiki to md and git commit on cron
#
# shellcheck disable=SC1117,SC2034
# SC1117: Backslash is literal in "\n". Prefer explicit escaping: "\\n".
# SC2034: GIT_SSH_COMMAND appears unused. Verify it or export it.
#
# requires
# apt-get install pandoc bc
# git clone https://github.com/peterjc/mediawiki_to_git_md
#   set:
#   convert.py: prefix = ""
#               default_layout = "default"
#               #handle.write("permalink: %s\n" % make_url(title).encode("utf-8"))
# add key to ~/.ssh/my-github-key
# chmod 400 ~/.ssh/my-github-key
# add github personal token to ~/token
#
# usage: ./wiki_to_md.sh &> /dev/null

SITE="drew.invadelabs.com"
DIR="/var/www/$SITE"
DATE=$(date '+%Y%m%d%H%M%S%z')
GITDIR="/tmp/$SITE.$DATE"
GIT_SSH_COMMAND="ssh -i ~/.ssh/jenkins-invadelabs -o StrictHostKeyChecking=no"
TOKEN=$(cat /root/github_token)

mkdir "$GITDIR"
cd "$GITDIR" || exit

git_init_dir () {
  # curl -H "Authorization: token $TOKEN" \
  # -d '{"name": "drewwiki", "default_branch":"temp"}' \
  # https://api.github.com/repos/invadelabs/drewwiki

  # delete gh-pages branch, create master branch, push it, delete, and initalize again
  curl  -H "Authorization: token $TOKEN" \
    -X DELETE https://api.github.com/repos/invadelabs/drewwiki/git/refs/heads/gh-pages
  mkdir "$GITDIR"
  cd "$GITDIR" || exit
  git init
  touch temp
  git add temp
  git commit -m "initial commit"
  git remote add origin git@github.com:invadelabs/drewwiki.git
  git push --set-upstream origin master
  curl  -H "Authorization: token $TOKEN" \
    -X DELETE https://api.github.com/repos/invadelabs/drewwiki/git/refs/heads/master
  cd ~ || exit
  rm -rf "$GITDIR"

  mkdir "$GITDIR"
  cd "$GITDIR" || exit
  git init
  git config user.name "Drew Holt"
  git config user.email "drew@invadelabs.com"

  git checkout -b gh-pages
}

export_xml () {
  php "$DIR"/maintenance/dumpBackup.php \
    --quiet \
    --conf "$DIR"/LocalSettings.php \
    --full \
    --include-files \
    --uploads > "$GITDIR"/drewwiki.xml
}

mediawiki_to_git_md () {
  touch "$GITDIR"/user_blocklist.txt
  echo "Drew	Drew Holt <drew@invadelabs.com>" > "$GITDIR"/usernames.txt
  IGNORE="*.sql *.xml"
  echo "$IGNORE" | tr ' ' '\n' > "$GITDIR"/.gitignore

  /root/mediawiki_to_git_md/convert.py "$GITDIR"/drewwiki.xml

  git add user_blocklist.txt .gitignore usernames.txt
  git commit -m "add files for mediawiki_to_git_md"
}

adjust_repo () {
  CONFIGYML="theme: jekyll-theme-primer"
  echo "$CONFIGYML" > "$GITDIR"/_config.yml
  echo "wiki.invadelabs.com" > "$GITDIR"/CNAME
  git add _config.yml CNAME
  git commit -m "add _config.yml CNAME"

  mv Main_Page.md index.md
  cp index.md README.md
  sed -i 's/ \"wikilink/.md \"wikilink/' README.md
  git add index.md README.md
  git commit -m "move Main_Page.md to README.md and link index.md to it"

  mkdir mediawiki
  git mv ./*.mediawiki mediawiki/
  git commit -m "move *.mediawiki to mediawiki/ dir"
}

git_reduce_size () {
  git gc
  git gc --aggressive
  git prune
}

git_push () {
  git remote add origin git@github.com:invadelabs/drewwiki.git
  git push -u origin gh-pages -f
}

slack_msg () {
  if [ ! -f /root/scripts/slacktee.sh ]; then
    curl -sS -o /root/scripts/slacktee.sh https://raw.githubusercontent.com/course-hero/slacktee/master/slacktee.sh
    chmod 755 /root/scripts/slacktee.sh
  fi
  echo "$1" | \
  /root/scripts/slacktee.sh \
  --config /root/slacktee.conf \
  -e "git push -u origin gh-pages -f" "$STATUS "\
  -t "https://invadelabs.github.io/drewwiki" \
  -a good \
  -p \
  -c general \
  -u "$(basename "$0")" \
  -i fast_forward \
  -l https://invadelabs.github.io/drewwiki > /dev/null;
}

cleanup () {
  rm -rf "$GITDIR"
}

START=$(date +%s)

git_init_dir &> /dev/null
export_xml
mediawiki_to_git_md &> /dev/null
adjust_repo &> /dev/null
git_reduce_size &> /dev/null
STATUS=$(git_push)
COMMIT="$(git rev-parse HEAD | cut -c -7)"

END=$(date +%s)
DIFF=$(echo "$END - $START" | bc)

slack_msg "Commit $COMMIT took ${DIFF}s https://github.com/invadelabs/drewwiki/commit/$COMMIT" > /dev/null

cleanup
