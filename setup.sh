#!/bin/bash
# Back up setup 
# set this up in cron to run every 10 minutes

echo "cronlog: $(hostname)-$(date -u +%Y-%m-%d\ %H:%M%Z)" >> /home/thor/cron/logs/setup

cd /home/thor/.setup
# eval $(ssh-agent) 
echo syntaxoverl0rd | ssh-add /home/thor/.ssh/id_ed25519

git add --all 
git commit -m "$(hostname)-$(date -u +%Y-%m-%d\ %H:%M%Z)" 
git pull 
git push


