#!/usr/bin/env fish
# rotate the logs for a cron script

set LOGFILE $argv[1]
set ONE_MB 1048576 # bytes


function rotate_log_inspect
  # If $LOGFILE is over 1mb in size, bump it back a number, and bump everything else back too
  if test -f $LOGFILE
    set size (wc -c $LOGFILE | string split " ")[1]
    if test size -ge $ONE_MB
      # do this first so that we log to $LOGFILE, not $LOGFILE.1
      mv $LOGFILE $LOGFILE.tmp
      echo "INFO: Rotating Logs. Moved $LOGFILE to $LOGFILE.1"
      rotate_logs
      mv $LOGFILE.tmp $LOGFILE.1
    end
  end
end

function rotate_logs
  for i in (seq 8 -1 1) # 8 7 .. 1
    if test -f $LOGFILE.$i
      echo "moving $LOGFILE.$i to $LOGFILE.$i_"
      set i_ (math "$i+1")
      mv $LOGFILE.$i $LOGFILE.$i_
    end
  end
end

rotate_logs_inpspect &>> $LOGFILE
