#!/bin/bash
# Back up setup 
# set this up in cron to run every 10 minutes

echo "cronlog: $(hostname)-$(date -u +%Y-%m-%d\ %H:%M%Z)" >> /home/thor/cron/logs/setup

cd /home/thor/.setup
# Need to start an ssh agent to be able to push to github
if [[ -z "$SSH_AUTH_SOCK" ]] ; then 
  eval $(ssh-agent) 
  ssh-add -k /home/thor/.ssh/id_ed25519_cron
fi

git add --all 
git commit -m "$(hostname)-$(date -u +%Y-%m-%d\ %H:%M%Z)" 
git pull 
git push

# kill the ssh-agent
ssh-agent -k
unset SSH_AUTH_SOCK
unset SSH_AGENT_PID
