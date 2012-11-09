GITROOT="$( cd -P "$( dirname "$SOURCE" )" && git root )"

# add scripts dir to $PATH
while [ -h "$SOURCE" ] ; do SOURCE="$(readlink "$SOURCE")"; done
DIR="$GITROOT/scripts"
export PATH=$PATH:$DIR

# Config
source $GITROOT/default/config

# VIM
alias vi='TERM="xterm-256color" vim'
alias vim='TERM="xterm-256color" vim'
export EDITOR=vim

# Grep
alias "ack-grep"="ack-grep -a --sort-files"

# Git
alias "g"="git"
alias "git-new-workdir"="/usr/share/doc/git/contrib/workdir/git-new-workdir"
#export GIT_PROXY_COMMAND="proxy"

# RVM
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
PATH=$PATH:$HOME/.rvm/bin
# default gemset
rvm $DEFAULT_GEMSET
