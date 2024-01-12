#!/usr/bin/fish
# commands run on one machine that should be run on all machines to keep everyone in-sync

set LOGFILE /home/thor/.cron/logs/sync_updates.log
rm ${LOGFILE}.6
mv ${LOGFILE}.5 "${LOGFILE}.6"
mv ${LOGFILE}.4 "${LOGFILE}.5"
mv ${LOGFILE}.3 "${LOGFILE}.4"
mv ${LOGFILE}.2 "${LOGFILE}.3"
mv ${LOGFILE}.1 "${LOGFILE}.2"
mv ${LOGFILE}   "${LOGFILE}.1"

# disable noise errors that X display cannot be opened
set -x DISPLAY :0

echo -e "\ncronlog: $(hostname)-$(date -u +%Y-%m-%d\ %H:%M%Z)\n" >> $LOGFILE

