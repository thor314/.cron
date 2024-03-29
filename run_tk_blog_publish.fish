#!/bin/fish 
# copy and publish files to my blog and maybe other places

set LOGFILE $HOME/.cron/logs/run_tk_blog_publish.log
# don't commit in these internal dirs. Must use fully qualified name, i.e. $HOME/.files
set BIN_DIR $HOME/projects/tk-blog-publish
set PATH $PATH $HOME/.cargo/bin # ensure that we can use cargo

fish ~/.cron/help_scripts/cron_init.fish $LOGFILE
if test -d $BIN_DIR
  cd $BIN_DIR
  # build, move, run binary
  git symbolic-ref -q HEAD >> /dev/null || git checkout main
  cargo build --release
  cp target/release/tk-blog-publish $HOME/.cargo/bin
  tk-blog-publish all
end &>> $LOGFILE

