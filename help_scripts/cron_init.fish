#!/usr/bin/fish

set LOGFILE $argv[1]
# rotate the logs
if test -f $LOGFILE 
  # important: don't use $HOME, since sudo wants an absolute path
  fish /home/thor/.cron/help_scripts/rotate_logs.fish $LOGFILE
else
  echo "WARNING: creating new logfile" >> $LOGFILE 
end

function init
  # disable noisy errors that X display cannot be opened
  set -gx DISPLAY :0 
  # ensure keychain is running
  source /home/thor/.files/fish/functions.fish 
  if not tk-keychain /home/thor/.ssh/id_ed25519
    echo "ERROR: failed to set up keychain" && exit 1
  end
  # write a pretty log message
  set -gx COMMIT_MSG (hostname)-(date -u +%Y-%m-%d-%H:%M%Z)
  echo ============================
  echo -e "cronlog: $COMMIT_MSG\n"
  echo ============================
end
init &>> $LOGFILE

