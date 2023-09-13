#!/usr/bin/env fish
# remove crap from my home 

echo -e "\ncronlog: $(hostname)-$(date -u +%Y-%m-%d\ %H:%M%Z)\n" >> /home/thor/.cron/logs/clean_home.log

set files_to_remove ~/.bash_history ~/.lesshst ~/.viminfo ~/.wget-hsts ~/.gp_history ~/.selected_editor ~/.sudo_as_admin_succesful ~/.bash_logout ~/.bashrc ~/.python_history .tsconfig.json 
set dirs_to_remove ~/.dotnet ~/.trash

for f in $files_to_remove
  if test -e $f
    echo "Removing file: $f"
    rm $f
  end
end

for d in $dirs_to_remove
  if test -d $d
    echo "Removing file: $d"
    rm $d -r
  end
end

