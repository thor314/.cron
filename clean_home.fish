#!/usr/bin/env fish
# remove crap from my home 

set LOGFILE ~/.cron/logs/clean_home.log
set FILES ~/.bash_history ~/.lesshst ~/.viminfo ~/.wget-hsts ~/.gp_history ~/.selected_editor ~/.sudo_as_admin_successful ~/.bash_logout ~/.bashrc ~/.python_history ~/.tsconfig.json 
set DIRS ~/.dotnet ~/.trash ~/.1password ~/.java ~/.gap .jupyter .vscode-insiders ~/.fltk ~/.jmol

function clean_home
  fish ~/.cron/help_scripts/cron_init.fish $LOGFILE

  for f in $FILES
      if test -f $f
          echo "Removing file: $f" 
          rm $f
      end
  end
  for d in $DIRS
      if test -d $d
          echo "Removing dir: $d" 
          rm $d -r
      end
  end
end

clean_home &>> $LOGFILE
