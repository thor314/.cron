#!/usr/bin/env fish
# rotate the logs for a cron script.
# $LOGFILE should contain only the most recent log. 
# on creation of a new log, move the contents of $LOGFILE to append to $LOGFILE.1.
# If $LOGFILE.1 exceeds $MAX_SIZE, rotate it to $LOGFILE.2, and so on.

set LOGFILE $argv[1]
set MAX_SIZE 100000 # about 100kb, keep up to 1MB in history for each log in total

function rotate -d "rotate the logs"
  if test -f $LOGFILE # 
    cat $LOGFILE >> $LOGFILE.1 && rm $LOGFILE
  end

end


function rotate_logs_inspect
  # If $LOGFILE is over $MAX_SIZE, bump it back a number, and bump everything else back too
  if test -f $LOGFILE
    set size (wc -c $LOGFILE | string split " ")[1]
    if test $size -ge $MAX_SIZE
      # do this first so that we log to $LOGFILE, not $LOGFILE.1
      echo "INFO: $LOGFILE has size $size."
      rotate_logs
      mv $LOGFILE $LOGFILE.1
      echo "INFO: Rotating Logs. Moved $LOGFILE to $LOGFILE.1"
    end
  else 
    echo "INFO: rotate_logs, nothing to do"
  end
end

function rotate_logs
  for i in (seq 8 -1 1) # 8 7 .. 1
    if test -f $LOGFILE.$i
      set i_ (math "$i+1")
      echo "moving $LOGFILE.$i to $LOGFILE.$i_"
      # implicitly, this will overwrite $LOGFILE.9 if it is time to do so
      mv $LOGFILE.$i $LOGFILE.$i_
    end
  end
end

rotate_logs_inspect &>> $LOGFILE
# rotate &>> $LOGFILE
