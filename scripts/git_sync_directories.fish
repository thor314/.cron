#!/usr/bin/env fish
# visit common directories and git pull

set LOGFILE $HOME/.cron/logs/git_sync_directories.log
set DIRS $HOME/{.setup, .cron, .private, .keep, .files}

fish ~/.cron/help_scripts/cron_init.fish $LOGFILE

for dir in $DIRS
    cd $dir && git pull &>>$LOGFILE
end
