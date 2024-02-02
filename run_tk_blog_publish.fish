#!/bin/fish 
# copy and publish files to my blog and maybe other places

set LOGFILE $HOME/.cron/logs/run_tk_blog_publish.log
set COMMIT_MSG $(hostname)-$(date -u +%Y-%m-%d-%H:%M%Z)
# don't commit in these internal dirs. Must use fully qualified name, i.e. $HOME/.files
set BIN_DIR /home/thor/projects/tk-blog-publish
set PATH $PATH /home/thor/.cargo/bin # ensure that we can use cargo

if test -d $BIN_DIR
  fish ~/.cron/help_scripts/rotate_logs.sh $LOGFILE
  set -x DISPLAY :0 # disable noisy errors that X display cannot be opened
  echo CRONLOG: $COMMIT_MSG

  cd $BIN_DIR
  # build, move, run binary
  git symbolic-ref -q HEAD >> /dev/null || git checkout main
  cargo build --release
  cp target/release/tk-blog-publish /home/thor/.cargo/bin
  tk-blog-publish all
end &>> $LOGFILE

