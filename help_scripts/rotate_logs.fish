#!/usr/bin/env fish
# rotate the logs for a cron script

set LOGFILE $argv[1]

if test -f $LOGFILE.9
  rm $LOGFILE.9
end

for i in (seq 8 -1 1)
  if test -f $LOGFILE.i
    set i_ (math "$i+1")
    mv $LOGFILE.i $LOGFILE.i_
  end
end

if test -f $LOGFILE 
  mv $LOGFILE "$LOGFILE.1"
else 
  echo "no such logfile: $LOGFILE"
end

