#!/usr/bin/env fish
# update my name commits on github

set LOGFILE ~/.cron/logs/github_name.log

function tk-github-name
  fish ~/.cron/help_scripts/cron_init.fish $LOGFILE
  /usr/bin/python3 /home/thor/projects/github_name/main.py --backdate=1 
end

tk-github-name &>> $LOGFILE

