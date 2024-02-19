#!/usr/bin/env fish
# rotate the logs for a cron script.
# $LOGFILE should contain only the most recent log. 
# on creation of a new log, move the contents of $LOGFILE to append to $LOGFILE.1.
# If $LOGFILE.1 exceeds $MAX_SIZE, rotate it to $LOGFILE.2, and so on.

set LOGFILE $argv[1]
set MAX_SIZE 100000 # about 100kb, keep up to 1MB in history for each log in total

function rotate_logs -d "rotate the logs"
  set size_first_archive (wc -c $LOGFILE.1 | string split " ")[1]
  if test $size_first_archive_1 -ge $MAX_SIZE
    echo "INFO: rotating log history"
    for i in (seq 8 -1 1) # 8 7 .. 1
      if test -f $LOGFILE.$i
        set i_ (math "$i+1")
        echo "moving $LOGFILE.$i to $LOGFILE.$i_"
        # implicitly overwrite $LOGFILE.9 if exists
        mv $LOGFILE.$i $LOGFILE.$i_
      end
    end
  end
end

# first rotate the base log
if test -f $LOGFILE 
  cat $LOGFILE >> $LOGFILE.1 && rm $LOGFILE
end
# then rotate history, if applicable
rotate_logs &>> $LOGFILE
