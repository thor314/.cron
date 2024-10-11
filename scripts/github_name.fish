#!/usr/bin/env fish
# update my name commits on github

set LOGFILE ~/.cron/logs/github_name.log

function tk-github-name
    /usr/bin/python3 $HOME/projects/github_name/main.py --backdate=1
end

fish ~/.cron/help_scripts/cron_init.fish $LOGFILE
tk-github-name &>>$LOGFILE
