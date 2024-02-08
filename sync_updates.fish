#!/usr/bin/fish
# commands run on one machine that should be run on all machines to keep everyone in-sync

set LOGFILE /home/thor/.cron/logs/sync_updates.log

# disable noise errors that X display cannot be opened
function sync 
  fish ~/.cron/help_scripts/cron_init.fish $LOGFILE

  echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  for d in $HOME/{.files,.private}/install.conf.yaml 
    /home/thor/.local/bin/dotbot -c $d
    echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  end

  # fish $HOME/.cron/help_scripts/sync.fish 
end 

sync &>> $LOGFILE
