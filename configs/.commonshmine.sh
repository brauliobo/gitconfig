while [ -h "$SOURCE" ] ; do SOURCE="$(readlink "$SOURCE")"; done
GITROOT="$( cd -P "$( dirname "$SOURCE" )" && git root )"
# Config
source $GITROOT/default/config

# add scripts dir to $PATH
DIR="$GITROOT/scripts"
export PATH=$PATH:$DIR

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
[ -n "$DEFAULT_GEMSET"] && rvm $DEFAULT_GEMSET
