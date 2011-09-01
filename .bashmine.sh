#!/bin/bash

#RubyGEMS
export PATH=$HOME/.gem/ruby/1.8/bin:$PATH

alias vi="vim"                                                                                                                                                                                  
alias vim='TERM="xterm-256color" vim'
export EDITOR=vim                                                                                                                                                                               
alias "ack-grep"="ack-grep -a"
alias "g"="git"
complete -o default -o nospace -F _git g
