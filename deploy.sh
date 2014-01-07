#!/bin/bash

# from http://stackoverflow.com/questions/9271381/how-can-i-parse-long-form-arguments-in-shell
_setArgs() {
  while [ "$1" != "" ]; do
    case $1 in "-o" | "--overwrite")
      opt_overwrite=$1
      ;;
    esac
    case $1 in "-v" | "--verbose")
      opt_verbose=$1
      ;;
    esac
    shift
  done
}
_setArgs $*

test $opt_verbose && set -x

echo == Link configurations files not overwriting existing regular files
for f in `ls -A configs`; do
  [[ -L $HOME/$f || $opt_overwrite ]] && rm $HOME/$f
  ln -s $PWD/configs/$f $HOME/$f
done

while [ -h "$SOURCE" ]; do SOURCE="$(readlink "$SOURCE")"; done
GITROOT="$(builtin cd -P "$(dirname "$SOURCE")" && git root)"
echo == Source $GITROOT/default/config
source $GITROOT/default/config

echo == Update submodules
git smuir --quiet

echo == Install Oh my ZSH
if [[ ! -x $HOME/.oh-my-zsh ]]; then
  wget --no-check-certificate https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh
fi

if [[ $INSTALL_RVM == 1 ]]; then
  echo == Install RVM
  if [[ ! -x $HOME/.rvm ]]; then
    curl -#L https://get.rvm.io | bash -s stable
  fi
fi

echo == Add autoload configs code
if ! grep zshmine.sh $HOME/.zshrc > /dev/null; then
  echo '. $HOME/.zshmine.sh' >> ~/.zshrc
fi
if ! grep bashmine.sh $HOME/.bashrc > /dev/null; then
  echo '. $HOME/.bashmine.sh' >> ~/.bashrc
  echo '. $HOME/.bashmine.sh' >> ~/.bash_profile
fi

echo == Grab gems credentials
if [[ -n "$RUBYGEMS_USER" && ! -f ~/.gem/credentials ]]; then
  mkdir -p ~/.gem
  curl -u $RUBYGEMS_USER https://rubygems.org/api/v1/api_key.yaml > ~/.gem/credentials
fi

echo == Install hooks
find -L .git/hooks -type f ! '(' -name '*.sample' ')' -delete
for h in `ls $GITROOT/hooks`; do
  ln -sf $GITROOT/hooks/$h $GITROOT/.git/hooks
done
