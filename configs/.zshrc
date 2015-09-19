# ubuntu missed this
emulate sh -c 'source /etc/profile'

# load prezto
source ~/.zprezto/runcoms/zshrc

# don't put commands starting with space on history
setopt HIST_IGNORE_SPACE

# allow array simple loop from string
set -o shwordsplit

# disable autocorrection
unsetopt correct_all
DISABLE_CORRECTION="true"

alias zshconfig="vim ~/.zshrc"
alias zshsource="source ~/.zshrc"

# load shell init
. $HOME/.zshmine.sh

# word navigation with control arrows
bindkey '5D' emacs-backward-word
bindkey '5C' emacs-forward-word
