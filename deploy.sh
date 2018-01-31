#!/bin/bash

EMAIL="drew@invadelabs.com"
REPO_DIR="/home/drew/invadelabs.com";
COMMIT=$(git -C "$REPO_DIR" log -1 --decorate=no | head -1)

git -C "$REPO_DIR" pull;

# exit if REPO_DIR does not exist
if [ ! -d "$REPO_DIR" ]; then
  exit 1
fi

rsync -av --delete --exclude .git/ "$REPO_DIR"/ /var/www/invadelabs.com/ | mailx -s "invadelabs.com $COMMIT deployed to site" "$EMAIL"
