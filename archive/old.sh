#!/bin/bash
# in crontab:
# 0 0,3,6,9,12,15,18,21 * * * /usr/bin/bash /home/thor/.cron/dotfiles.sh >> /home/thor/.cronlog/dotfiles.txt

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/thor/.local/bin

dotbot -c $HOME/.files/install.conf.yaml
dotbot -c $HOME/.files/private/install.conf.yaml

msg="$(hostname)-$(date -u +%Y-%m-%d)"
update() {
  git add --all
  git commit -m "$msg"
  git pull
  git push
}

# SUBMODULES=(private obsidian helix setup archive/.emacs.d archive/.doom.d)
cd $HOME/.files
GITS=($(grep path .gitmodules | sed 's/\s*path = //') "./")
for d in $GITS; do
  echo "pushd: " && pushd $d
  printf "\nupdating $d\n"
  update
  echo "popd: " && popd
done
