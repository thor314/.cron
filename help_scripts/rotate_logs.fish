#!/usr/bin/env fish
# rotate the logs for a cron script.
# $LOGFILE should contain only the most recent log. 
# on creation of a new log, move the contents of $LOGFILE to append to $LOGFILE.1.
# If $LOGFILE.1 exceeds $MAX_SIZE, rotate it to $LOGFILE.2, and so on.

set LOGFILE $argv[1]
set MAX_SIZE 100000 # about 100kb, keep up to 1MB in history for each log in total

function rotate_logs -d "rotate the logs"
  init_log_message
  set size_archive (wc -c $LOGFILE.1 | string split " ")[1]
  if test $size_archive -ge $MAX_SIZE
    echo "INFO: rotating log history"
    for i in (seq 8 -1 1) # 8 7 .. 1
      if test -f $LOGFILE.$i
        set i_ (math "$i+1")
        echo "INFO: moving $LOGFILE.$i to $LOGFILE.$i_"
        # implicitly overwrite $LOGFILE.9 if exists
        mv $LOGFILE.$i $LOGFILE.$i_
      end
    end
  else ; echo "INFO: rotate_logs: no rotation required" ; end
end

function init_log_message
  set COMMIT_MSG (hostname)-(date -u +%Y-%m-%d-%H:%M%Z)
  echo -e "\n============================"
  echo "cronlog: $COMMIT_MSG"
  echo -e "============================\n"
end

# first rotate the base log
if test -f $LOGFILE 
  cat $LOGFILE >> $LOGFILE.1 && rm $LOGFILE
end
# then rotate history, if applicable
rotate_logs &>> $LOGFILE

