#!/usr/bin/env fish
# remove crap from my home 

set LOGFILE '$HOME/.cron/logs/clean_home.log'
rm $LOGFILE.6
mv $LOGFILE.5 "$LOGFILE.6"
mv $LOGFILE.4 "$LOGFILE.5"
mv $LOGFILE.3 "$LOGFILE.4"
mv $LOGFILE.2 "$LOGFILE.3"
mv $LOGFILE.1 "$LOGFILE.2"
mv $LOGFILE   "$LOGFILE.1"

# disable noise errors that X display cannot be opened
set -x DISPLAY :0 &>> $LOGFILE
set files ~/.bash_history ~/.lesshst ~/.viminfo ~/.wget-hsts ~/.gp_history ~/.selected_editor ~/.sudo_as_admin_successful ~/.bash_logout ~/.bashrc ~/.python_history ~/.tsconfig.json 
set dirs ~/.dotnet ~/.trash ~/.1password ~/.java ~/.gap .jupyter .vscode-insiders ~/.fltk ~/.jmol

echo -e "\ncronlog: $(hostname)-$(date -u +%Y-%m-%d\ %H:%M%Z)\n" &>> $LOGFILE

for f in $files
    if test -f $f
        echo "Removing file: $f" 
        rm $f
    end
end &>> $LOGFILE

for d in $dirs
    if test -d $d
        echo "Removing dir: $d" 
        rm $d -r
    end
end &>> $LOGFILE 

