#!/bin/bash
# Back up private dotfiles and run dotbot
# set this up in cron to run every 10 minutes

echo "cronlog: $(hostname)-$(date -u +%Y-%m-%d\ %H:%M%Z)" >> /home/thor/cron/logs/private

cd /home/thor/.private
eval $(ssh-agent) 
echo syntaxoverl0rd | ssh-add /home/thor/.ssh/id_ed25519

git add --all && git commit -m "$(hostname)-$(date -u +%Y-%m-%d\ %H:%M%Z)" 
git pull 
git push
/home/thor/.local/bin/dotbot -c install.conf.yaml

