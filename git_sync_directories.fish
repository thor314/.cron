#!/usr/bin/env fish
# Back up dotfiles and run dotbot for multiple dirs
# Set this up in cron to run every 10 minutes

set LOGFILE $HOME/.cron/logs/git_sync_directories.log
fish ~/.cron/help_scripts/rotate_logs.sh $LOGFILE
set COMMIT_MSG $(hostname)-$(date -u +%Y-%m-%d-%H:%M%Z)

# List of directories to process
set DIRS $HOME/.setup $HOME/.cron $HOME/.private $HOME/.keep 
set DIRS $DIRS $HOME/.files 
# do not create noisy sync commits in projects, do this manually
set DIRS_NOCOMMIT $HOME/projects 

# this can be run in config.fish, uncomment if ever ssh failure issues
# function ssh-ensure
#   # start an ssh agent. Avoid change to this section. Debugging ssh key permissions is annoying.
#   # output keychain ssh-agent shell info into this script and source it
#   eval (keychain --eval -Q) # -Q is "quick" not quiet
#   # This will not work! keychain --eval -Q
#   # make sure the cron key is added
#   keychain --nogui ~/.ssh/id_ed25519 -Q
#   # this should output some keys. If not, we're borked.
#   echo known ssh keys: (keychain -L) 
# end

function update-dirs
  set dirs $argv[1..-2]
  set nocommit $argv[-1]
  # disable noisy errors that X display cannot be opened
  set -x DISPLAY :0 

  echo ============================ 
  echo -e "cronlog: $COMMIT_MSG"    
  echo "updating $dirs..."          
  echo ============================ 

  # Loop through each directory and perform operations
  for dir in $dirs ; update-dir $dir $nocommit ; end 

  echo -e "Finished syncing" 
  echo "===================================" 
end

function update-dir 
  set dir $argv[1] 
  set nocommit $argv[2]
  cd $dir 
  echo "--------------------------------"
  echo -e "visiting $dir" 

  if test -f .gitmodules; update-submodules $dir $nocommit ; end

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
      git checkout main
      git pull && git push 
      echo \"--------------------------------\"
    "
  else
    git submodule foreach "
      echo \"visiting $dir\" 
      git pull && git push 
      git checkout main
      git add . 
      git diff --cached --exit-code --quiet || git commit -m \"$COMMIT_MSG\"
      git pull && git push 
      echo \"--------------------------------\"
    "
  end

  echo "updated $dir submodules" 
  echo "********************************"
end

# ssh-ensure                   &>> $LOGFILE
update-dirs $DIRS          0 &>> $LOGFILE
update-dirs $DIRS_NOCOMMIT 1 &>> $LOGFILE
