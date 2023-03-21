#!/bin/bash
# Back up private dotfiles and run dotbot
# set this up in cron to run every 10 minutes

echo "cronlog: $(hostname)-$(date -u +%Y-%m-%d\ %H:%M%Z)" >> /home/thor/cron/logs/private

cd /home/thor/.private
if [[ -z "$SSH_AUTH_SOCK" ]] ; then 
  eval $(ssh-agent) 
  # echo syntaxoverl0rd | ssh-add /home/thor/.ssh/id_ed25519
  ssh-add -k /home/thor/.ssh/id_ed25519_cron
fi

git add --all && git commit -m "$(hostname)-$(date -u +%Y-%m-%d\ %H:%M%Z)" 
git pull 
git push
/home/thor/.local/bin/dotbot -c install.conf.yaml

# kill the ssh-agent
ssh-agent -k
unset SSH_AUTH_SOCK
unset SSH_AGENT_PID
