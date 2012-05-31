alias vi="vim"                                                                                                                                                                                  
alias vim='TERM="xterm-256color" vim'
export EDITOR=vim                                                                                                                                                                               

alias "ack-grep"="ack-grep -a"

alias "g"="git"
alias "git-new-workdir"="/usr/share/doc/git/contrib/workdir/git-new-workdir"
#export GIT_PROXY_COMMAND="proxy"

# RVM
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" 
PATH=$PATH:$HOME/.rvm/bin

# default rvm gemset
rvm 1.8.7@noosfero

# add scripts dir to $PATH
while [ -h "$SOURCE" ] ; do SOURCE="$(readlink "$SOURCE")"; done
DIR="$( cd -P "$( dirname "$SOURCE" )" && git root )/scripts"                                                                                            
export PATH=$PATH:$DIR
