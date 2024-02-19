#!/usr/bin/env fish
# search for instances of failures and warnings in logs, create 

# important: don't use $HOME, since this will be run by root
set LOGFILE /home/thor/.cron/logs/notify_log_failures.log

function notify-log-failures
  fish /home/thor/.cron/help_scripts/cron_init.fish $LOGFILE
  set logfiles (ls /home/thor/.cron/logs | rg ".*\.log\$")
  for f in $logfiles 
    echo -e "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo "INFO: searching logfile $f for issues"
    echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
    # search $f for instances of warning or error strings
    rg -A2 "(W:|fatal|WARNING|ERROR|bad|exit|terminate|E:)" $f
  end 
end

notify-log-failures &>> $LOGFILE

