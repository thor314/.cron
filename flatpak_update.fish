#!/usr/bin/env fish
# apt update. must be run with sudo.

set LOGFILE ~/.cron/logs/flatpak_update.log

function tk-flatpak-update
  /usr/bin/flatpak update --user -y 
end

fish ~/.cron/help_scripts/cron_init.fish $LOGFILE
tk-flatpak-update &>> $LOGFILE

