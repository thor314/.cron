#!/usr/bin/env fish
# apt update. must be run with sudo.

function tk-apt-update
    # apt-get not apt. apt will warn about non-stable cli interface.
    DEBIAN_FRONTEND=noninteractive apt-get update
    apt-get -y upgrade
    apt-get autoremove
end

tk-apt-update
