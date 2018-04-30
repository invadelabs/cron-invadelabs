#!/bin/bash
# Drew Holt <drew@invadelabs.com>
# script to git pull latest master and rsync to live site

EMAIL="drew@invadelabs.com"
REPO_DIR="/home/drew/invadelabs.com";
COMMIT=$(git -C "$REPO_DIR" log -1 --decorate=no | head -1)

# exit if REPO_DIR does not exist or rsync will try to copy the contents of
# of /
if [ ! -d "$REPO_DIR" ]; then
  exit 1
fi

# pull latest master branch
git -C "$REPO_DIR" pull;

# rsync latest git master branch to live site
rsync () {
  rsync -av --delete --exclude .git/ "$REPO_DIR"/ /var/www/invadelabs.com/
}

# send a message
mailer () {
  mailx -s "invadelabs.com $COMMIT deployed to site" "$EMAIL"
}

# run and keep log as variable
RSYNC=$(rsync)

# send log off via email
echo "$RSYNC" | mailer
