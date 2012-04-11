alias vi="vim"                                                                                                                                                                                  
alias vim='TERM="xterm-256color" vim'
export EDITOR=vim                                                                                                                                                                               
alias "ack-grep"="ack-grep -a"
alias "g"="git"
alias "git-new-workdir"="/usr/share/doc/git/contrib/workdir/git-new-workdir"

# RVM
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" 
PATH=$PATH:$HOME/.rvm/bin

# default rvm gemset
rvm 1.8.7@noosfero
