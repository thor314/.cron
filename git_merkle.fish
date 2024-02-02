#!/usr/bin/env fish
# sync my merkle tree of gitmodules.
# Back up dotfiles and run dotbot for multiple dirs
# Set this up in cron to run every 10 minutes

set LOGFILE $HOME/.cron/logs/git_merkle.log
fish ~/.cron/help_scripts/rotate_logs.sh $LOGFILE
set COMMIT_MSG $(hostname)-$(date -u +%Y-%m-%d-%H:%M%Z)
source $HOME/.files/fish/functions.fish

# List of directories to process
set DIR $HOME/gm
# disable noisy errors that X display cannot be opened
set -x DISPLAY :0 
# don't commit in these internal dirs
set COMMIT_WHITELIST empty

# this can be run in config.fish, uncomment if ever ssh failure issues
# function ssh-ensure
#   # start an ssh agent. Avoid change to this section. Debugging ssh key permissions is annoying.
#   # output keychain ssh-agent shell info into this script and source it
#   eval (keychain --eval -Q) # -Q is "quick" not quiet
#   # This will not work! keychain --eval -Q
# end

# Assuming that tree is mirror-only, not used to work in:
# On the way down: updating
## INTERNAL NODE: switch from commit hash to main. All internal nodes have only the main branch.
## Pull from upstream if there have been any changes on other machines, and update.
## `git pull && git submodule update --init` # not recursive: need to pull again first. Init new submodules.
## descend and repeat until a leaf is reached. 
## LEAF NODE: We do not work in the leaf nodes, so we should not have to do anything there. 
# On the way up: committing
## INTERNAL NODE: We should now be confident that all internal nodes are updated. 
## `git commit -m $COMMIT_MSG` && git push
function recurse-to-bottom -d "Recursively update git submodules"
  set dir $argv[1]
  pushd $dir

  if test -f .gitmodules ### INTERNAL NODE
    # On the way down: updating
    git checkout main && git pull && git submodule update --init
    set -l modules (git config --file .gitmodules --get-regexp path | awk '{ print $2 }')
    for m in $modules
      if test -d $m 
        echo "from $(pwd), entering submodule: $m"
        recurse-to-bottom $m
      else # submodule has been removed incorrectly: removed directory but not .gitmodules entry
        echo -e "\n**WARNING**: thor sloppy, many such cases. $m must be removed from .gitmodules manually.\n"
      end
    end

    # On the way up: committing
    set -l is_changes (git status --porcelain)
    set -l thisdir (tk-path-to-name (pwd))
    if test -n "$is_changes" 
      if not contains $thisdir $COMMIT_WHITELIST
        update -m # do commit in internal nodes
      else 
        echo "$thisdir is in commit whitelist, no commits"
        update 
      end
    else
      echo "no changes detected in $(pwd)."
    end
  else ### LEAF NODE
    # Don't commit in the leaves.
    update 
  end

  popd
end

function update -d "Update git submodule"
  # checkout the main branch (sometimes submodules switch to commit hash rather than main)
  # then pull if there are upstream changes. 
  # assume that there are changes in this repo.
  # commit if there changes here and we are instructed to do so
  # otherwise we are in a leaf, and just leave it at pulling.
  echo updating from (pwd)
  argparse 'm/modify' -- $argv
  or return 1

  git checkout (__git.default_branch) # stay on the main branch

  set -l remote_branch (git rev-parse --abbrev-ref --symbolic-full-name @{u})
  set -l upstream_changes (git diff --quiet HEAD $remote_branch; and echo 0; or echo 1)
  if test $upstream_changes -eq 1
    git pull
  end

  if set -q _flag_m
    # we're in an internal node, and committing changes.
    echo "Committing changes in $(pwd)..."
    git add .
    git commit -m $COMMIT_MSG
    git push
    return 0
  else
    echo "pulling from leaf dir $(pwd)"
    return 0
  end

  echo "no changes in $(pwd)"
end

if test -d $HOME/gm
  source $HOME/.files/fish/functions.fish # tk-path-to-name function
  # ssh-ensure                 &>> $LOGFILE
  recurse-to-bottom $HOME/gm &>> $LOGFILE
else
  echo "gm not found"        &>> $LOGFILE
end

