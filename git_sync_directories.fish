#!/usr/bin/env fish
# Back up dotfiles and run dotbot for multiple dirs
# Set this up in cron to run every 10 minutes

set LOGFILE $HOME/.cron/logs/git_sync_directories.log
set COMMIT_MSG $(hostname)-$(date -u +%Y-%m-%d-%H:%M%Z)

# List of directories to sync. Assume these all use ONLY the main branch.
set DIRS $HOME/.setup $HOME/.cron $HOME/.private $HOME/.keep 
set DIRS $DIRS $HOME/.files 
# do not create noisy sync commits in work dirs
set DIRS_NOCOMMIT $HOME/projects $HOME/cryptography

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

  if test -d $dir 
    pushd $dir && echo "--------------------------------"
    echo -e "$dir: visiting" 

    if test -f .gitmodules; update-submodules $dir $_flag_c ; end

    if not set -q _flag_c
      echo "$dir: nocommit"
      git push && git pull 
    else
      if test (git status --porcelain) 
        echo "$dir: commit"
        git add --all && git commit -m \"$COMMIT_MSG\" 
        git push && git pull 
      end
    end

    echo "--------------------------------" && popd
  end
end

function update-submodules
  argparse 'c/commit' -- $argv
  set dir $argv[1]

  echo "********************************"
  echo "updating $dir submodules" 
  git pull 
  git submodule update --init

  if not git symbolic-ref -q HEAD >> /dev/null # detached HEAD state, checkout main
    git checkout main
  # else ; set branch_name (git symbolic-ref --short HEAD)
  end

  if not set -q _flag_c
    git submodule foreach "
      git checkout main
      echo \"$dir: visiting submodule, nocommit\" 
      git push && git pull
    " 
  else
    git submodule foreach "
      echo \"$dir: visiting submodule, commit\" 
      git add --all . && git commit -m \"$COMMIT_MSG\"
      git push && git pull
      echo \"--------------------------------\"
    " 
  end

  echo "updated $dir submodules" 
  echo "********************************"
end

if set -q DIRS 
  fish ~/.cron/help_scripts/rotate_logs.sh $LOGFILE
  set -x DISPLAY :0 # disable noisy errors that X display cannot be opened

  echo ============================ 
  echo -e "cronlog: $COMMIT_MSG"    
  echo "updating $dirs..."          
  echo ============================ 

  ssh-ensure                   

  update-dirs $DIRS -c
  echo -e "Finished syncing commit dirs" 
  echo "===================================" 
  echo -e "Finished syncing commit dirs" 
  update-dirs $DIRS_NOCOMMIT 
end &>> $LOGFILE
