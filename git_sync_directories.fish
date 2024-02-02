#!/usr/bin/env fish
# Back up dotfiles and run dotbot for multiple dirs
# Set this up in cron to run every 10 minutes

set LOGFILE $HOME/.cron/logs/git_sync_directories.log
set COMMIT_MSG $(hostname)-$(date -u +%Y-%m-%d-%H:%M%Z)

# List of directories to process
set DIRS $HOME/.setup $HOME/.cron $HOME/.private $HOME/.keep 
set DIRS $DIRS $HOME/.files 
# do not create noisy sync commits in projects, do this manually
set DIRS_NOCOMMIT $HOME/projects 

# this can be run in config.fish, uncomment if ever ssh failure issues
function ssh-ensure; eval (keychain --eval -Q); end
#   keychain --nogui ~/.ssh/id_ed25519 -Q # maybe the same thing, not sure
#   echo known ssh keys: (keychain -L)  # this should output some keys. If not, we're borked.

function update-dirs
  argparse 'c/commit' -- $argv
  set dirs $argv
  # Loop through each directory and perform operations
  for dir in $dirs ; update-dir $dir $_flag_c ; end 
end

function update-dir 
  argparse 'c/commit' -- $argv
  set dir $argv[1] 

  cd $dir 
  echo "--------------------------------"
  echo -e "visiting $dir" 

  if test -f .gitmodules; update-submodules $dir $_flag_c ; end

  echo "updating $dir" 
  if test $nocommit -eq 1  
    echo "nocommit"
  else
    git add --all 
    git diff --cached --exit-code --quiet || git commit -m \"$COMMIT_MSG\"
  end
  git pull && git push 
  echo "leaving $dir " 

  echo "--------------------------------"
end

function update-submodules
  set dir $argv[1]
  set nocommit $argv[2]
  echo "********************************"
  echo "updating $dir submodules" 
  # need the git diff line, or submodule will exit early
  if test $nocommit -eq 1  
    git submodule foreach "
      echo \"visiting $dir\" 
      echo \"nocommit\"
      git pull && git push 
      git pull && git push 
      echo \"--------------------------------\"
    " # git checkout main - don't do
  else
    git submodule foreach "
      echo \"visiting $dir\" 
      git pull && git push 
      git add . 
      git diff --cached --exit-code --quiet || git commit -m \"$COMMIT_MSG\"
      git pull && git push 
      echo \"--------------------------------\"
    " # git checkout main
  end

  echo "updated $dir submodules" 
  echo "********************************"
end

if set -q DIRS 
  # disable noisy errors that X display cannot be opened
  set -x DISPLAY :0 
  fish ~/.cron/help_scripts/rotate_logs.sh $LOGFILE

  echo ============================ 
  echo -e "cronlog: $COMMIT_MSG"    
  echo "updating $dirs..."          
  echo ============================ 

  ssh-ensure                   

  update-dirs $DIRS -c
  echo -e "Finished syncing commit dirs" 
  echo "===================================" 
  echo -e "Finished syncing commit dirs" 
  update-dirs $DIRS_NOCOMMIT 1
end &>> $LOGFILE
