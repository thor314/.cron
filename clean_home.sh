#!/usr/bin/env fish
# remove crap from my home 

set LOGFILE ~/.cron/logs/clean_home.log
fish ~/.cron/help_scripts/rotate_logs.sh $LOGFILE
set files ~/.bash_history ~/.lesshst ~/.viminfo ~/.wget-hsts ~/.gp_history ~/.selected_editor ~/.sudo_as_admin_successful ~/.bash_logout ~/.bashrc ~/.python_history ~/.tsconfig.json 
set dirs ~/.dotnet ~/.trash ~/.1password ~/.java ~/.gap .jupyter .vscode-insiders ~/.fltk ~/.jmol

function clean_home
  # disable noise errors that X display cannot be opened
  set -x DISPLAY :0 

  echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  echo -e "\ncronlog: $(hostname)-$(date -u +%Y-%m-%d\ %H:%M%Z)\n" 
  echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  for f in $files
      if test -f $f
          echo "Removing file: $f" 
          rm $f
      end
  end

  echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  for d in $dirs
      if test -d $d
          echo "Removing dir: $d" 
          rm $d -r
      end
  end
end

clean_home &>> $LOGFILE
