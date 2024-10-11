#!/usr/bin/fish
set LOGFILE $argv[1]

function init
    # disable noisy errors that X display cannot be opened
    set -gx DISPLAY :0

    # ensure keychain is running
    source $HOME/.files/fish/functions.fish
    if not tk-keychain $HOME/.ssh/id_ed25519
        echo "ERROR: failed to set up keychain" && exit 1
    end
    echo "INFO: cron init successfully set up"
end

fish $HOME/.cron/help_scripts/rotate_logs.fish $LOGFILE
init &>>$LOGFILE
