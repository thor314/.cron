#!/usr/bin/env fish
# rustup update

set LOGFILE ~/.cron/logs/rustup_update.log

function tk-rustup-update
  fish ~/.cron/help_scripts/cron_init.fish $LOGFILE
  /home/thor/.cargo/bin/rustup update 

  # update all binaries
  if not command -q cargo-update 
    echo "INFO: install cargo update"
    cargo install cargo-install-update
  end
  cargo install-update -a # update all binary packages
end

tk-rustup-update &>> $LOGFILE


