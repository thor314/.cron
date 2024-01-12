#!/usr/bin/env fish
# Back up dotfiles and run dotbot for multiple dirs
# Set this up in cron to run every 10 minutes

# List of directories to process
set LOGFILE $HOME/.cron/logs/sync_dirs.log
set dirs $HOME/.files $HOME/.setup $HOME/.cron $HOME/.private $HOME/.keep 
set dirs $dirs $HOME/img/backgrounds $HOME/img/profile $HOME/img/official-images 
set dirs $dirs $HOME/blog $HOME/obsidian-setup
# to remove:
set dirs $dirs $HOME/invoice $HOME/official 

rm $LOGFILE

echo -e "\ncronlog: $(hostname)-$(date -u +%Y-%m-%d\ %H:%M%Z)\n" >> $LOGFILE 

# disable noise errors that X display cannot be opened
fish set -x DISPLAY :0

# fish shell-specific:
eval (ssh-agent -c) >> $LOGFILE
ssh-add /home/thor/.ssh/id_ed25519_cron >> $LOGFILE ^&1

# bash shell equivalent: 
# eval $(ssh-agent) >> /home/thor/log
# ssh-add /home/thor/.ssh/id_ed25519_cron >> /home/thor/log 2>&1

# Loop through each directory and perform operations
for dir in $dirs
    cd $dir 
    echo -e "\n visiting $dir \n" >> $LOGFILE

    # This will throw errors for oh-my-zsh, this is fine
    git submodule foreach git add --all
    git submodule foreach git commit -m $(hostname)-(date -u +%Y-%m-%d\ %H:%M%Z)
    git submodule foreach git pull
    git submodule foreach git push 

    git add --all
    git commit -m $(hostname)-$(date -u +%Y-%m-%d\ %H:%M%Z)
    git pull
    git push && notify-send "Success" "successful"

    echo -e "\n leaving $dir \n" >> $LOGFILE
end

# Kill the ssh-agent, don't leak resources
ssh-agent -k >> $LOGFILE

/home/thor/.local/bin/dotbot -c /home/thor/.files/install.conf.yaml
/home/thor/.local/bin/dotbot -c /home/thor/.private/install.conf.yaml

