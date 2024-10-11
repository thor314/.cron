#!/usr/bin/env fish
# remove crap from my home directory

set LOGFILE ~/.cron/logs/clean_home.log
set FILES ~/{.bash_history, .lesshst, .viminfo, .wget-hsts, .gp_history, .selected_editor, .sudo_as_admin_successful, .bash_logout, .bashrc, .python_history, .tsconfig.json}
set DIRS ~/{.dotnet, .trash, .1password, .java, .gap, .jupyter, .vscode-insiders, .fltk, .jmol}


function clean_home
    echo "cleaning files: $FILES"
    for f in $FILES
        if test -f $f
            echo "INFO: Removing file: $f"
            rm $f || echo "WARNING: could not remove $f"
        end
    end

    echo -e "\ncleaning dirs: $DIRS"
    for d in $DIRS
        if test -d $d
            echo "INFO: Removing dir: $d"
            rm $d -r || echo "WARNING: could not remove $d"
        end
    end
end

fish ~/.cron/help_scripts/cron_init.fish $LOGFILE
clean_home &>>$LOGFILE
