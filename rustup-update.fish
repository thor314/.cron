#!/usr/bin/env fish
# apt update. must be run with sudo.

set LOGFILE ~/.cron/logs/apt.log

function tk-apt-update
  fish ~/.cron/help_scripts/cron_init.fish $LOGFILE
  # apt-get not apt. apt will warn about non-stable cli interface.
  DEBIAN_FRONTEND=noninteractive apt-get update 
  apt-get -y upgrade 
end

tk-apt-update &>> $LOGFILE


