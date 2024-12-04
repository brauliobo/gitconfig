while [ -h "$SOURCE" ]; do SOURCE="$(readlink "$SOURCE")"; done
GITROOT="$(builtin cd -P "$(dirname "$SOURCE")" && git root)"

SCRIPTS="$GITROOT/scripts"
LOCALS="$GITROOT/locals"
CUSTOM_PATHS=:$SCRIPTS
CUSTOM_PATHS+=:$LOCALS

# Config
[[ -f $GITROOT/locals/envs ]] && source $GITROOT/locals/envs

# clear custom paths to avoid duplication
PATH=$(echo $PATH | sed "s|$CUSTOM_PATHS:||g")
# add custom paths
export PATH=$CUSTOM_PATHS:$PATH

case $RUBY_FROM in
rvm)
  if [[ -x $HOME/.rvm ]]; then
    #if ! (env | grep PATH | grep .rvm > /dev/null); then
    source "$HOME/.rvm/scripts/rvm"
    #fi
  fi
  if [[ -x /usr/local/rvm ]]; then
    source "/usr/local/rvm/scripts/rvm"
  fi

  rvm use system >/dev/null 2>&1
  if [ -f .ruby-version ]; then rvm use $(cat .ruby-version); fi

  ;;
rbenv)
  __rvm_unload
  ;;
esac

# VIM
alias vi=nvim
alias vim=nvim

# EDITOR
export EDITOR=nvim
export VISUAL=$EDITOR
export GIT_EDITOR=$EDITOR

# GEM
alias "gem-clear"='for i in `gem list --no-versions`; do gem uninstall -aIx $i; done'
alias be="bundle exec"

# NPM
alias "npm-clear"="sudo npm list -g --depth=0. | grep -v npm | awk -F ' ' '{print $2}' | awk -F '@' '{print $1}'  | sudo xargs npm remove -g"

# Git
alias "g"="git"
if [[ -r /usr/share/doc/git/contrib/workdir/git-new-workdir ]]; then
  alias "git-new-workdir"="/usr/share/doc/git/contrib/workdir/git-new-workdir"
else
  alias "git-new-workdir"="/usr/share/git/workdir/git-new-workdir"
fi
#export GIT_PROXY_COMMAND="proxy"

# GREP
# the_silver_searcher
#alias "ag"="ag"

export GOPATH=$SCRIPTS
export PATH=$HOME/.local/bin:$PATH

# android sdk
export ANDROID_HOME=$HOME/android-sdk
export PATH=$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH

alias vpnrun="function f() { CC=\$1; shift 1; vopono -v exec --custom ~/openvpn/brauliobo@gmail.com_'$CC'_7E4B0.ovpn --protocol openvpn \"\$@\" }; f"

if [ -f ../env.sh ]; then source ../env.sh; fi

alias cp="cp --reflink=auto"
alias rm="rm --one-file-system"

alias jq="jq -C"

# tmux
[ -f ../tmux-start ] && TMUX_START=../tmux-start
#[ -f ./tmux-start ] && TMUX_START=./tmux-start
if [ -n "$TMUX_START" ] && [[ "$(tmux display-message -p -F '#{window_index}')" == 1 ]]; then
  if [[ -z "${TMUX_PARENT}" ]]; then
    ~/.tmux.conf.d/nested-tmux/new-tmux
  elif [[ "$(tmux display-message -p -F '#{session_windows}')" == 1 ]]; then
    source $TMUX_START
  fi
fi
