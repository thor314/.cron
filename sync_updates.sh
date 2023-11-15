#!/usr/bin/fish
# commands run on one machine that should be run on all machines to keep everyone in-sync

set logfile /home/thor/.cron/logs/sync_updates.log
rm $LOGFILE
# disable noise errors that X display cannot be opened
fish set -x DISPLAY :0

echo -e "\ncronlog: $(hostname)-$(date -u +%Y-%m-%d\ %H:%M%Z)\n" >> $LOGFILE

