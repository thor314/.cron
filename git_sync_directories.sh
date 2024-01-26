#!/usr/bin/env fish
# Back up dotfiles and run dotbot for multiple dirs
# Set this up in cron to run every 10 minutes

set LOGFILE $HOME/.cron/logs/sync_dirs.log
fish ~/.cron/help_scripts/rotate_logs.sh $LOGFILE
set COMMIT_MSG $(hostname)-$(date -u +%Y-%m-%d-%H:%M%Z)

# List of directories to process
set DIRS $HOME/.setup $HOME/.cron $HOME/.private $HOME/.keep 
# these dirs contain submodules
set DIRS $DIRS $HOME/projects $HOME/.files 

function update-dirs
    set dirs $argv
    # disable noisy errors that X display cannot be opened
    set -x DISPLAY :0 

    echo ============================ 
    echo -e "cronlog: $COMMIT_MSG"    
    echo "updating $dirs..."          
    echo ============================ 

    # start an ssh agent. Avoid change to this section. Debugging ssh key permissions is annoying.
    eval (keychain --eval -Q) # output keychain ssh-agent shell info into this script and source it
    keychain --nogui ~/.ssh/key-thor-cron # make sure the cron key is added
    echo known ssh keys: (keychain -L) # this should output some keys. If not, we're borked.

    # Loop through each directory and perform operations
    for dir in $dirs ; update-dir $dir ; end 

    echo -e "Finished syncing" 
    echo "===================================" 
    # 2024-01-25 keychain update - this should no longer be necessary
    # Kill the ssh-agent, don't leak resources
    # ssh-agent -k 
end

function update-dir 
    set dir $argv[1] 
    cd $dir 
    echo "--------------------------------"
    echo -e "visiting $dir" 

    if test -f .gitmodules; update-submodules $dir ; end
    echo "updating $dir" 
    git add --all 
    git diff --cached --exit-code --quiet || git commit -m \"$COMMIT_MSG\"
    git pull && git push 
    # notify-send "Directory updated" "successfully updated $dir" # mid
    echo "leaving $dir " 

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
      git checkout main
      git diff --cached --exit-code --quiet || git commit -m \"$COMMIT_MSG\"
      git pull && git push 
      echo \"--------------------------------\"
      "
      # && notify-send \"Submodule updated\" \"successfully updated $dir\" 
    echo "updated $dir submodules" 
    echo "********************************"
end

update-dirs $DIRS &>> $LOGFILE
