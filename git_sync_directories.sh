#!/usr/bin/env fish
# Back up dotfiles and run dotbot for multiple directories
# Set this up in cron to run every 10 minutes

# List of directories to process
set directories /home/thor/.files /home/thor/.setup /home/thor/.cron /home/thor/.private /home/thor/r/tmpl /home/thor/.keep /home/thor/img/backgrounds /home/thor/img/profile /home/thor/blog

echo -e "\ncronlog: $(hostname)-$(date -u +%Y-%m-%d\ %H:%M%Z)\n" >> /home/thor/.cron/logs/sync_dirs.log

echo "before" >> /home/thor/.cron/log
ssh-add -l >> /home/thor/.cron/log
# start an ssh agent to talk to github and add the key
eval $(ssh-agent -s) >> /home/thor/.cron/log
ssh-add -k /home/thor/.ssh/id_ed25519_cron >> /home/thor/.cron/log
echo "after" >> /home/thor/.cron/log
ssh-add -l >> /home/thor/.cron/log

# Loop through each directory and perform operations
for dir in $directories
    cd $dir 
    echo -e "\n visiting $dir \n" >> /home/thor/.cron/logs/sync_dirs.log

    # This will throw errors for oh-my-zsh, this is fine
    git submodule foreach git add --all
    git submodule foreach git commit -m $(hostname)-(date -u +%Y-%m-%d\ %H:%M%Z)
    git submodule foreach git pull
    git submodule foreach git push

    git add --all
    git commit -m $(hostname)-$(date -u +%Y-%m-%d\ %H:%M%Z)
    git pull
    git push

    echo -e "\n leaving $dir \n" >> /home/thor/.cron/logs/sync_dirs.log
end

# Kill the ssh-agent
# ssh-agent -k
# set -e SSH_AUTH_SOCK
# set -e SSH_AGENT_PID

/home/thor/.local/bin/dotbot -c /home/thor/.files/install.conf.yaml
/home/thor/.local/bin/dotbot -c /home/thor/.private/install.conf.yaml

