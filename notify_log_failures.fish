#!/usr/bin/env fish
# search for instances of failures and warnings in logs, create 

# important: don't use $HOME, since this will be run by root
set LOGFILE /home/thor/.cron/logs/notify_log_failures.log
set PATH $PATH /home/thor/.cargo/bin

function notify-log-failures
  set logfiles (ls /home/thor/.cron/logs | rg ".*\.log\$")
  echo "INFO: searching $logfiles for failures"
  for f in $logfiles 
    set f /home/thor/.cron/logs/$f
    echo -e "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo "INFO: searching logfile $f for issues"
    echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
    # search $f for instances of warning or error strings, ignore case
    rg -A2 -i "(fatal|warning|error|bad|exit|terminate)" $f
  end 
  echo "INFO: finished searching logs for failures"
end

fish /home/thor/.cron/help_scripts/cron_init.fish $LOGFILE
notify-log-failures &>> $LOGFILE
