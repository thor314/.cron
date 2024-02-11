#!/usr/bin/env fish
# rotate the logs for a cron script

set LOGFILE $argv[1]
set ONE_MB 1048576 # bytes


function rotate_logs
  # if logfile.9 is overflowing, remove it
  if test -f $LOGFILE.9 
    set size (wc -c $LOGFILE.9 | string split " ")[1]
    if test size -ge $ONE_MB
      echo "INFO: removing $LOGFILE.9"
      rm $LOGFILE.9 || echo "WARNING: No such file $LOGFILE.9"
    end
  end

  for i in (seq 8 -1 1)
    if test -f $LOGFILE.$i
      set i_ (math "$i+1")
      mv $LOGFILE.$i $LOGFILE.$i_ || echo "WARNING: No such file $LOGFILE.$i"
    end
  end

  if test -f $LOGFILE 
    mv $LOGFILE "$LOGFILE.1"
  else 
    echo "ERROR: no such logfile: $LOGFILE"
  end
end

rotate_logs &>> $LOGFILE
