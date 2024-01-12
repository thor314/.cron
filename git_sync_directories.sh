#!/usr/bin/env fish
# Back up dotfiles and run dotbot for multiple dirs
# Set this up in cron to run every 10 minutes

# List of directories to process
set LOGFILE $HOME/.cron/logs/sync_dirs.log
set dirs $HOME/.setup $HOME/.cron $HOME/.private $HOME/.keep 
set dirs $dirs $HOME/projects # contains submodules
set dirs $dirs $HOME/.files # contains submodules
set COMMIT_MSG "$(hostname)-$(date -u +%Y-%m-%d\ %H:%M%Z)"

# rotate the log file, could be more sophisticated, but..meh
rm $LOGFILE 

echo ============================ &>> $LOGFILE
echo -e "cronlog: $COMMIT_MSG"    &>> $LOGFILE 
echo "updating $dirs..."          &>> $LOGFILE
echo ============================ &>> $LOGFILE

# disable noise errors that X display cannot be opened
fish set -x DISPLAY :0 &>> $LOGFILE

# fish shell-specific:
eval (ssh-agent -c) &>> $LOGFILE
ssh-add /home/thor/.ssh/id_ed25519_cron &>> $LOGFILE 
# In bash, this is equivalent to (don't uncomment or remove)
# eval $(ssh-agent) >> /home/thor/log
# ssh-add /home/thor/.ssh/id_ed25519_cron >> /home/thor/log 2>&1

# Loop through each directory and perform operations
for dir in $dirs
    cd $dir 
    echo "--------------------------------"
    echo -e "visiting $dir" 

    if test -f .gitmodules
      echo "********************************"
      echo "updating $dir submodules" 
      git submodule foreach "
        echo -e \"visiting $dir\" 
        git add . && 
        git diff --cached --exit-code --quiet || git commit -m \"$COMMIT_MSG\"; 
        git pull && 
        git push
        echo \"--------------------------------\"
        "
      echo "updated $dir submodules" 
      echo "********************************"
    end

    echo  "updating $dir" 
    git add --all 
    git commit -m $COMMIT_MSG
    git pull 
    git push && notify-send "Success" "successfully updated $dir" 

    echo -e "leaving $dir " 
    echo "--------------------------------"
end &>> $LOGFILE 

echo -e "Finished syncing" 
echo "==================================="
# Kill the ssh-agent, don't leak resources
ssh-agent -k &>> $LOGFILE

/home/thor/.local/bin/dotbot -c /home/thor/.files/install.conf.yaml &>> $LOGFILE
/home/thor/.local/bin/dotbot -c /home/thor/.private/install.conf.yaml &>> $LOGFILE

