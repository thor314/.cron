#!/usr/bin/env fish
# Back up dotfiles and run dotbot for multiple dirs
# Set this up in cron to run every 10 minutes

# disable noisy errors that X display cannot be opened
set LOGFILE $HOME/.cron/logs/sync_dirs.log
set -x DISPLAY :0 &>> $LOGFILE
set COMMIT_MSG "$(hostname)-$(date -u +%Y-%m-%d\ %H:%M%Z)"

# List of directories to process
set dirs $HOME/.setup $HOME/.cron $HOME/.private $HOME/.keep 
# these dirs contain submodules
set dirs $dirs $HOME/projects 
set dirs $dirs $HOME/.files 

# rotate the log file, could be more sophisticated, but..meh
rm $LOGFILE 

echo ============================ &>> $LOGFILE
echo -e "cronlog: $COMMIT_MSG"    &>> $LOGFILE 
echo "updating $dirs..."          &>> $LOGFILE
echo ============================ &>> $LOGFILE

# fish shell-specific:
eval (ssh-agent -c) &>> $LOGFILE
ssh-add $HOME/.ssh/id_ed25519_cron &>> $LOGFILE 
echo 3 && sleep 5
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
      # need the git diff line, or submodule will exit early
      git submodule foreach "
        echo -e \"visiting $dir\" 
        git add . 
        git diff --cached --exit-code --quiet || git commit -m \"$COMMIT_MSG\"
        git pull 
        git push && notify-send "Submodule updated" "successfully updated $dir" 
        echo \"--------------------------------\"
        "
      echo "updated $dir submodules" 
      echo "********************************"
    end

    echo  "updating $dir" 
    git add --all 
    git commit -m $COMMIT_MSG
    git pull 
    git push && notify-send "Directory updated" "successfully updated $dir" 

    echo -e "leaving $dir " 
    echo "--------------------------------"
end &>> $LOGFILE 

echo -e "Finished syncing" &>> $LOGFILE
echo "===================================" &>> $LOGFILE
# Kill the ssh-agent, don't leak resources
ssh-agent -k &>> $LOGFILE

/home/thor/.local/bin/dotbot -c /home/thor/.files/install.conf.yaml &>> $LOGFILE
/home/thor/.local/bin/dotbot -c /home/thor/.private/install.conf.yaml &>> $LOGFILE

