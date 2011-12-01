#!/bin/bash

alias vi="vim"                                                                                                                                                                                  
alias vim='TERM="xterm-256color" vim'
export EDITOR=vim                                                                                                                                                                               
alias "ack-grep"="ack-grep -a"
alias "g"="git"
complete -o default -o nospace -F _git g

rvm 1.8.7@noosfero
