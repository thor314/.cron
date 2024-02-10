#!/usr/bin/env fish
# Back up dotfiles and run dotbot for multiple dirs
# Set this up in cron to run every 10 minutes

set LOGFILE $HOME/.cron/logs/git_sync_directories.log

# List of directories to sync. Assume these all use ONLY the main branch.
set COMMIT_MSG $(hostname)-$(date -u +%Y-%m-%d-%H:%M%Z)
set DIRS $HOME/{.setup, .cron, .private, .keep, .files}
# do not create noisy sync commits in work dirs, just the root dir
set DIRS_NOCOMMIT $HOME/{projects, cryptography}

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
    echo -e "INFO: $dir: visiting" 

    git symbolic-ref -q HEAD >> /dev/null || git checkout main
    if test -f .gitmodules; update-submodules $dir $_flag_c ; end

    if not set -q _flag_c
      echo "INFO: $dir: no commit"
      git push && git pull 
    else
      if not test -z "$(git status --porcelain)"
        echo "INFO: $dir: with commit"
        git add --all && git commit -m \"$COMMIT_MSG\" 
        git push && git pull 
      else 
        echo "INFO: $dir: no changes"
      end
    end

    echo "--------------------------------" && popd
  end
end

function update-submodules
  argparse 'c/commit' -- $argv
  set dir $argv[1]

  echo "********************************"
  echo "INFO: $dir: updating" 
  git pull 
  git submodule update --init
  git symbolic-ref -q HEAD >> /dev/null || git checkout main
  git add --all . && git commit -m \"$COMMIT_MSG\"
  git push && git pull

  echo "INFO: updating $dir submodules" 
  if not set -q _flag_c
    git submodule foreach "
      echo \"INFO: $dir: visiting submodule, nocommit\" 
      git symbolic-ref -q HEAD >> /dev/null || git checkout main
      git push && git pull
    " 
  else
    git submodule foreach "
      echo \"INFO: $dir: visiting submodule, commit\" 
      git symbolic-ref -q HEAD >> /dev/null || git checkout main
      git add --all . && git commit -m \"$COMMIT_MSG\"
      git push && git pull
      echo \"--------------------------------\"
    " 
  end

  echo "INFO: updated $dir submodules" 
  echo "********************************"
end

if set -q DIRS 
  fish ~/.cron/help_scripts/cron_init.fish $LOGFILE

  update-dirs $DIRS -c
  echo -e "INFO: \nFinished syncing commit dirs\n" 
  update-dirs $DIRS_NOCOMMIT 
end &>> $LOGFILE
