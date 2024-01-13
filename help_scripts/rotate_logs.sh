#!/usr/bin/env fish
# rotate the logs for a cron script

set LOGFILE $argv[1]

rm $LOGFILE.6
mv $LOGFILE.5 "$LOGFILE.6"
mv $LOGFILE.4 "$LOGFILE.5"
mv $LOGFILE.3 "$LOGFILE.4"
mv $LOGFILE.2 "$LOGFILE.3"
mv $LOGFILE.1 "$LOGFILE.2"
mv $LOGFILE   "$LOGFILE.1"

