#!/usr/bin/fish
# commands run on one machine that should be run on all machines to keep everyone in-sync

set LOGFILE /home/thor/.cron/logs/sync_updates.log
fish ~/.cron/help_scripts/rotate_logs.sh $LOGFILE

# disable noise errors that X display cannot be opened
set -x DISPLAY :0 &>> $LOGFILE

echo -e "\ncronlog: $(hostname)-$(date -u +%Y-%m-%d\ %H:%M%Z)\n" &>> $LOGFILE
fish $HOME/.files/scripts/sync.sh &>> $LOGFILE

