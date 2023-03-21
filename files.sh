#!/bin/bash
# Back up dotfiles and run dotbot
# set this up in cron to run every 10 minutes

echo "\ncronlog: $(hostname)-$(date -u +%Y-%m-%d\ %H:%M%Z)\n" >> /home/thor/cron/logs/files

cd /home/thor/.files
# Need to start an ssh agent to be able to push to github
if [[ -z "$SSH_AUTH_SOCK" ]] ; then 
  eval $(ssh-agent) 
  # echo syntaxoverl0rd | ssh-add /home/thor/.ssh/id_ed25519
  ssh-add -k /home/thor/.ssh/id_ed25519_cron
fi

# This will throw errors for oh-my-zsh, this is fine
git submodule foreach git add --all 
git submodule foreach git commit -m "$(hostname)-$(date -u +%Y-%m-%d\ %H:%M%Z)" 
git submodule foreach git pull
git submodule foreach git push

git add --all 
git commit -m "$(hostname)-$(date -u +%Y-%m-%d\ %H:%M%Z)" 
git pull 
git push 
/home/thor/.local/bin/dotbot -c install.conf.yaml

# kill the ssh-agent
ssh-agent -k
unset SSH_AUTH_SOCK
unset SSH_AGENT_PID
