while [ -h "$SOURCE" ] ; do SOURCE="$(readlink "$SOURCE")"; done
GITROOT="$( cd -P "$( dirname "$SOURCE" )" && git root )"
SCRIPTS="$GITROOT/scripts"
CUSTOM_PATHS=$SCRIPTS

# Config
source $GITROOT/default/config

# clear custom paths to avoid duplication
PATH=`echo $PATH | sed "s|$CUSTOM_PATHS:||g"`

# RVM
source "$HOME/.rvm/scripts/rvm"
rvm `cat $HOME/.ruby-version`

# add custom paths
export PATH=$CUSTOM_PATHS:$PATH

# VIM
alias vi='TERM="xterm-256color" vim'
alias vim='TERM="xterm-256color" vim'
export EDITOR=vim

# GEM
alias "gem-clear"='gem list | cut -d" " -f1 | xargs gem uninstall -aIx'

# Git
alias "g"="git"
alias "git-new-workdir"="/usr/share/doc/git/contrib/workdir/git-new-workdir"
#export GIT_PROXY_COMMAND="proxy"
