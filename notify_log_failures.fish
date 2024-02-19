#!/usr/bin/env fish
# search for instances of failures and warnings in logs, create 

# important: don't use $HOME, since this will be run by root
set LOGFILE /home/thor/.cron/logs/notify_log_failures.log

function notify-log-failures
  fish /home/thor/.cron/help_scripts/cron_init.fish $LOGFILE
  # apt-get not apt. apt will warn about non-stable cli interface.
  DEBIAN_FRONTEND=noninteractive apt-get update 
  apt-get -y upgrade 
  apt-get autoremove
end

tk-apt-update &>> $LOGFILE


