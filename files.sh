#!/bin/bash
# Back up dotfiles and run dotbot
# set this up in cron to run every 10 minutes

echo "\ncronlog: $(hostname)-$(date -u +%Y-%m-%d\ %H:%M%Z)\n" >> /home/thor/cron/cronlog-files

cd /home/thor/.files
# Need to start an ssh agent to be able to push to github
eval $(ssh-agent) 
echo syntaxoverl0rd | ssh-add /home/thor/.ssh/id_ed25519

git add --all 
git commit -m "$(hostname)-$(date -u +%Y-%m-%d\ %H:%M%Z)" 
git pull 
git push 
/home/thor/.local/bin/dotbot -c install.conf.yaml


