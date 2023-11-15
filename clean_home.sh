#!/usr/bin/env fish
# remove crap from my home 

set LOGFILE '/home/thor/.cron/logs/clean_home.log'
rm $LOGFILE 

echo -e "\ncronlog: $(hostname)-$(date -u +%Y-%m-%d\ %H:%M%Z)\n" >> $LOGFILE

# disable noise errors that X display cannot be opened
fish set -x DISPLAY :0

set files_to_remove ~/.bash_history ~/.lesshst ~/.viminfo ~/.wget-hsts ~/.gp_history ~/.selected_editor ~/.sudo_as_admin_successful ~/.bash_logout ~/.bashrc ~/.python_history ~/.tsconfig.json 

set dirs_to_remove ~/.dotnet ~/.trash ~/.1password

for f in $files_to_remove
    if test -e $f
        echo -e "Removing file: $f" >> $LOGFILE
        rm $f
    end
end

for d in $dirs_to_remove
    if test -d $d
        echo -e "Removing dir: $d" >> $LOGFILE
        rm $d -r
    end
end

