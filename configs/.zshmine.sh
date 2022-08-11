#!/bin/zsh

SOURCE="$0"
. ~/.commonshmine.sh

PROMPT='%(!.%{%F{yellow}%}.)$USER @ %{$fg[white]%}%M %{$fg_bold[red]%}➜ %{$fg_bold[green]%}%p %{$fg[cyan]%}%c %{$fg_bold[blue]%}$(git_prompt_info)%{$fg_bold[blue]%} % %{$reset_color%}'

