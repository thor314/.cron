#!/usr/bin/env fish
# Back up dotfiles and run dotbot for multiple directories
# Set this up in cron to run every 10 minutes

# List of directories to process
set directories /home/thor/.files /home/thor/.setup /home/thor/.cron /home/thor/.private /home/thor/r/tmpl /home/thor/.keep /home/thor/img/backgrounds /home/thor/img/profile /home/thor/blog

rm /home/thor/.cron/logs/sync_dirs.log
echo -e "\ncronlog: $(hostname)-$(date -u +%Y-%m-%d\ %H:%M%Z)\n" >> /home/thor/.cron/logs/sync_dirs.log

# disable noise errors that X display cannot be opened
fish set -x DISPLAY :0

# fish shell-specific:
eval (ssh-agent -c) >> /home/thor/.cron/logs/sync_dirs.log
ssh-add /home/thor/.ssh/id_ed25519_cron >> /home/thor/.cron/logs/sync_dirs.log ^&1

# bash shell equivalent: 
# eval $(ssh-agent) >> /home/thor/log
# ssh-add /home/thor/.ssh/id_ed25519_cron >> /home/thor/log 2>&1

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
    git push && notify-send "Success" "successful"

    echo -e "\n leaving $dir \n" >> /home/thor/.cron/logs/sync_dirs.log
end

# Kill the ssh-agent, don't leak resources
ssh-agent -k >> /home/thor/.cron/logs/sync_dirs.log

/home/thor/.local/bin/dotbot -c /home/thor/.files/install.conf.yaml
/home/thor/.local/bin/dotbot -c /home/thor/.private/install.conf.yaml

