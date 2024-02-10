#!/usr/bin/env fish
# rustup update

set LOGFILE ~/.cron/logs/rustup_update.log

function tk-rustup-update
  fish ~/.cron/help_scripts/cron_init.fish $LOGFILE
  /home/thor/.cargo/bin/rustup update 
end

tk-rustup-update &>> $LOGFILE


