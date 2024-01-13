#!/usr/bin/fish
# commands run on one machine that should be run on all machines to keep everyone in-sync

set LOGFILE /home/thor/.cron/logs/sync_updates.log
fish ~/.cron/help_scripts/rotate_logs.sh $LOGFILE

# disable noise errors that X display cannot be opened
function sync 
  set -x DISPLAY :0 
  echo -e "\ncronlog: $(hostname)-$(date -u +%Y-%m-%d\ %H:%M%Z)\n" 

  /home/thor/.local/bin/dotbot -c /home/thor/.files/install.conf.yaml 
  /home/thor/.local/bin/dotbot -c /home/thor/.private/install.conf.yaml 

  fish $HOME/.files/scripts/sync.sh 
end 

sync &>> $LOGFILE
