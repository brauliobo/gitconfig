#!/bin/bash

run() {
	set -x; $@ ; { set +x; } 2>/dev/null
}

# from http://stackoverflow.com/questions/9271381/how-can-i-parse-long-form-arguments-in-shell
_setArgs() {
    while [ "$1" != "" ]; do
        case $1 in
            "-o" | "--overwrite")
                opt_overwrite=$1
                ;;
        esac
        shift
    done
}
_setArgs $*

### Link configurations files not overwriting existing regular files
for f in `ls -A configs`; do
    [[ -L $HOME/$f || $opt_overwrite ]] && rm $HOME/$f
	run ln -s $PWD/configs/$f $HOME/$f
done

while [ -h "$SOURCE" ] ; do SOURCE="$(readlink "$SOURCE")"; done
GITROOT="$( cd -P "$( dirname "$SOURCE" )" && git root )"
### Config
source $GITROOT/default/config

### Update submodules
run git submodule update --init

### Install RVM
if [[ ! -x $HOME/.rvm ]]; then
	run curl -L https://get.rvm.io | bash -s stable
fi
### Install Oh my ZSH
if [[ ! -x $HOME/.oh-my-zsh ]]; then
	run wget --no-check-certificate https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh
fi

### Add autoload configs code
if ! grep zshmine.sh $HOME/.zshrc > /dev/null; then
    run echo '. $HOME/.zshmine.sh' >> ~/.zshrc
fi
if ! grep bashmine.sh $HOME/.bashrc > /dev/null; then
	run echo '. $HOME/.bashmine.sh' >> ~/.bashrc
	run echo '. $HOME/.bashmine.sh' >> ~/.bash_profile
fi

### grab gems credentials
mkdir -p ~/.gem
run curl -u $GEM_USER https://rubygems.org/api/v1/api_key.yaml > ~/.gem/credentials


