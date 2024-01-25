#!/usr/bin/env fish
# Back up dotfiles and run dotbot for multiple dirs
# Set this up in cron to run every 10 minutes

set LOGFILE $HOME/.cron/logs/sync_dirs.log
fish ~/.cron/help_scripts/rotate_logs.sh $LOGFILE
set COMMIT_MSG "$(hostname)-$(date -u +%Y-%m-%d-%H:%M%Z)"

# List of directories to process
set dirs $HOME/.setup $HOME/.cron $HOME/.private $HOME/.keep 
# these dirs contain submodules
set dirs $dirs $HOME/projects $HOME/.files 

function update-dirs
    set dirs $argv
    # disable noisy errors that X display cannot be opened
    set -x DISPLAY :0 

    echo ============================ 
    echo -e "cronlog: $COMMIT_MSG"    
    echo "updating $dirs..."          
    echo ============================ 

    # start an ssh agent
    keychain --eval -Q | source
    keychain --nogui ~/.ssh/key-thor-cron # if no key is not yet known, add key
    # ssh-add $HOME/.ssh/key-thor-cron # equivalent

    # Loop through each directory and perform operations
    echo dirs is $dirs
    for dir in $dirs ; update-dir $dir ; end 

    echo -e "Finished syncing" 
    echo "===================================" 
    # 2024-01-25 keychain update - this should no longer be necessary
    # Kill the ssh-agent, don't leak resources
    # ssh-agent -k 
end

function update-dir 
    set dir $argv[1] ; cd $dir 
    echo "--------------------------------"
    echo -e "visiting $dir" 

    if test -f .gitmodules; update-submodules $dir ; end
    echo "updating $dir" 
    git add --all 
    echo "a"
    git diff --cached --exit-code --quiet || git commit -m \"$COMMIT_MSG\"
    echo "b"
    git pull 
    echo "e"
    git push 
    echo "c" 
    notify-send "Directory updated" "successfully updated $dir" 
    echo "leaving $dir " 

      update-dir $dir
      echo "--------------------------------"
end

function update-submodules
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

update-dirs $dirs &>> $LOGFILE
