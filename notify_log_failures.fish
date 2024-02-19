#!/usr/bin/env fish
# search for instances of failures and warnings in logs, create 

# important: don't use $HOME, since this will be run by root
set LOGFILE /home/thor/.cron/logs/notify_log_failures.log

function notify-log-failures
  fish /home/thor/.cron/help_scripts/cron_init.fish $LOGFILE
  

  
end

function filenames-from-crontab -d "extract the non-sudo filenames from the crontab"
  cat /home/thor/.cron/crontab | # get the filenames
  sed '/# sudo crontab:/,$d'   | # remove the sudo section
  string match -vr "^#"        | # remove the comments
  string replace -r '.* /' ''  | # get the filenames
  string collect                 # remove trailing newline
end

tk-apt-update &>> $LOGFILE


