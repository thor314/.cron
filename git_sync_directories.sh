#!/usr/bin/env fish
# Back up dotfiles and run dotbot for multiple dirs
# Set this up in cron to run every 10 minutes

set LOGFILE $HOME/.cron/logs/sync_dirs.log
fish ~/.cron/help_scripts/rotate_logs.sh $LOGFILE
set COMMIT_MSG "$(hostname)-$(date -u +%Y-%m-%d\ %H:%M%Z)"

# List of directories to process
set dirs $HOME/.setup $HOME/.cron $HOME/.private $HOME/.keep 
# these dirs contain submodules
set dirs $dirs $HOME/projects 
set dirs $dirs $HOME/.files 

function update_dirs
    set dirs $argv
    # disable noisy errors that X display cannot be opened
    set -x DISPLAY :0 

    echo ============================ 
    echo -e "cronlog: $COMMIT_MSG"    
    echo "updating $dirs..."          
    echo ============================ 

    # fish shell-specific:
    eval (ssh-agent -c)
    ssh-add $HOME/.ssh/id_ed25519_cron 
    # In bash, this is equivalent to (don't uncomment or remove)
    # eval $(ssh-agent) >> /home/thor/log
    # ssh-add /home/thor/.ssh/id_ed25519_cron >> /home/thor/log 2>&1

    # Loop through each directory and perform operations
    for dir in $dirs
        cd $dir 
        echo "--------------------------------"
        echo -e "visiting $dir" 

        if test -f .gitmodules
          update_submodules $dir
        end

        update_dir $dir
        echo "--------------------------------"
    end 

    echo -e "Finished syncing" 
    echo "===================================" 
    # Kill the ssh-agent, don't leak resources
    ssh-agent -k 
end

function update_submodules
    set dir $argv[1]
    echo "********************************"
    echo "updating $dir submodules" 
    # need the git diff line, or submodule will exit early
    git submodule foreach "
      echo -e \"visiting $dir\" 
      git add . 
      git diff --cached --exit-code --quiet || git commit -m \"$COMMIT_MSG\"
      git pull && git push && notify-send \"Submodule updated\" \"successfully updated $dir\" 
      echo \"--------------------------------\"
      "
    echo "updated $dir submodules" 
    echo "********************************"
end

function update_dir
    set dir $argv[1]
    echo "updating $dir" 
    git add --all 
    git diff --cached --exit-code --quiet || git commit -m \"$COMMIT_MSG\"
    git pull && git push && notify-send "Directory updated" "successfully updated $dir" 
    echo "leaving $dir " 
end

update_dirs $dirs &>> $LOGFILE
