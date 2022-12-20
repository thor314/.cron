#!/bin/bash
# Back up crons
# set this up in cron to run every 10 minutes

echo "\ncronlog: $(hostname)-$(date -u +%Y-%m-%d\ %H:%M%Z)\n" >> /home/thor/cron/logs/cron

cd /home/thor/cron
# Need to start an ssh agent to be able to push to github
eval $(ssh-agent) 
echo syntaxoverl0rd | ssh-add /home/thor/.ssh/id_ed25519

# This will throw errors for oh-my-zsh, this is fine
git add --all 
git commit -m "$(hostname)-$(date -u +%Y-%m-%d\ %H:%M%Z)" 
git pull 
git push 
