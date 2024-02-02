#!/usr/bin/env fish
# sync my merkle tree of gitmodules.
# Back up dotfiles and run dotbot for multiple dirs
# Set this up in cron to run every 10 minutes

set LOGFILE $HOME/.cron/logs/git_merkle.log
# don't commit in these internal dirs. Must use fully qualified name, i.e. $HOME/.files
set COMMIT_WHITELIST empty

# Assuming that tree is mirror-only, not used to work in:
# On the way down: updating
## INTERNAL NODE: switch from commit hash to main. All internal nodes have only the main branch.
## Pull from upstream if there have been any changes on other machines, and update.
## `git pull && git submodule update --init` # not recursive: need to pull again first. Init new submodules.
## descend and repeat until a leaf is reached. 
## LEAF NODE: We do not work in the leaf nodes, so we should not have to do anything there. 
# On the way up: committing
## INTERNAL NODE: We should now be confident that all internal nodes are updated. 
## `git add --all . && git commit -m $COMMIT_MSG` && git push
function recurse-to-bottom -d "Recursively update git submodules"
  set dir $argv[1]
  pushd $dir

  if test -f .gitmodules ### INTERNAL NODE
    # On the way down: updating
    git checkout main && git pull && git submodule update --init
    set -l modules (git config --file .gitmodules --get-regexp path | awk '{ print $2 }')
    for m in $modules
      if test -d $m 
        echo "from $dir, entering submodule: $m"
        recurse-to-bottom $m
      else # submodule has been removed incorrectly: removed directory but not .gitmodules entry
        echo -e "\n**WARNING**: thor sloppy, many such cases. $m must be removed from .gitmodules manually.\n"
      end
    end

    # On the way up: committing
    set -l is_changes (git status --porcelain)
    if test -n "$is_changes" 
      if not contains (pwd) $COMMIT_WHITELIST
        update -m 
      else # no commit in COMMIT_WHITELIST dirs
        echo "$thisdir is in commit whitelist, no commits"
        update # noop
      end
    else
      echo "no changes detected in $(pwd)."
    end
  else ### LEAF NODE 
    update # noop
  end

  popd
end

function update -d "Commits changes. Assumes that there are changes to commit. Option to not commit, just log."
  argparse 'm/modify' -- $argv

  if set -q _flag_m
    # we're in an internal node, and committing changes.
    echo "Committing changes in $(pwd)..."
    git add . && git commit -m $COMMIT_MSG 
    git push && git pull
  else # No commit
    echo "Visited, but not committing in $(pwd)..."
    git push && git pull
  end
end

if test -d $HOME/gm
  fish ~/.cron/help_scripts/cron_init.fish $LOGFILE
  recurse-to-bottom $HOME/gm 
else
  echo "gm not found"       
end &>> $LOGFILE

