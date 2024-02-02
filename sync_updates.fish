#!/usr/bin/fish
# commands run on one machine that should be run on all machines to keep everyone in-sync

set LOGFILE /home/thor/.cron/logs/sync_updates.log

# disable noise errors that X display cannot be opened
function sync 
  fish ~/.cron/help_scripts/cron_init.fish $LOGFILE
  /home/thor/.local/bin/dotbot -c /home/thor/.files/install.conf.yaml 
  /home/thor/.local/bin/dotbot -c /home/thor/.private/install.conf.yaml 
  echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

  # fish $HOME/.cron/help_scripts/sync.fish 
end 

sync &>> $LOGFILE
