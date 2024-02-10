#!/usr/bin/env fish
# apt update

set LOGFILE ~/.cron/logs/clean_home.log

function tk-apt-update
  fish ~/.cron/help_scripts/cron_init.fish $LOGFILE
  # apt-get not apt. apt will warn about non-stable cli interface.
  DEBIAN_FRONTEND=noninteractive apt-get update 
  apt-get -y upgrade >> /home/thor/.cron/logs/apt.log 2>&1
end

tk-apt-update &>> $LOGFILE


