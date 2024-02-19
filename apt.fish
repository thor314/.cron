#!/usr/bin/env fish
# apt update. must be run with sudo.

# important: don't use $HOME, since this will be run by root
set LOGFILE /home/thor/.cron/logs/apt.log

function tk-apt-update
  # apt-get not apt. apt will warn about non-stable cli interface.
  DEBIAN_FRONTEND=noninteractive apt-get update 
  apt-get -y upgrade 
  apt-get autoremove
end

fish /home/thor/.cron/help_scripts/cron_init.fish $LOGFILE
tk-apt-update &>> $LOGFILE


