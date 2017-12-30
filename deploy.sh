#!/bin/bash

REPO_DIR="/home/drew/invadelabs.com"; git -C "$REPO_DIR" pull; rsync -av --delete --exclude .git/ "$REPO_DIR"/ /var/www/invadelabs.com/ | mailx -s "invadelabs.com $(git -C "$REPO_DIR" log -1 --decorate=no | head -1) deployed to site" drewderivative@gmail.com
