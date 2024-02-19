#!/usr/bin/env fish
# search for instances of failures and warnings in logs, create 

# important: don't use $HOME, since this will be run by root
set LOGFILE /home/thor/.cron/logs/notify_log_failures.log

function notify-log-failures
  fish /home/thor/.cron/help_scripts/cron_init.fish $LOGFILE

  
end

function filenames-from-crontab -d "extract the non-sudo filenames from the crontab"

end

tk-apt-update &>> $LOGFILE


