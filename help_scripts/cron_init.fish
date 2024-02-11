#!/usr/bin/fish

set LOGFILE $argv[1]
# important: don't use $HOME or ~ as shortcuts in this script. Use /home/thor.
# sudo may get confused, wants an absolute path

function init
  if test -f $LOGFILE 
    fish /home/thor/.cron/help_scripts/rotate_logs.fish $LOGFILE
  else
    echo "WARNING: creating new logfile" >> $LOGFILE 
  end

  set -gx COMMIT_MSG (hostname)-(date -u +%Y-%m-%d-%H:%M%Z)
  echo -e "\n============================"
  echo "cronlog: $COMMIT_MSG"
  echo -e "============================\n"

  # disable noisy errors that X display cannot be opened
  set -gx DISPLAY :0 

  # ensure keychain is running
  source /home/thor/.files/fish/functions.fish 
  if not tk-keychain /home/thor/.ssh/id_ed25519
    echo "ERROR: failed to set up keychain" && exit 1
  end
end

init &>> $LOGFILE

