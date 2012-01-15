#!/bin/zsh

unsetopt correct_all

alias vi="vim"                                                                                                                                                                                  
alias vim='TERM="xterm-256color" vim'
export EDITOR=vim                                                                                                                                                                               
alias "ack-grep"="ack-grep -a"
alias "g"="git"

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
rvm 1.8.7@noosfero
