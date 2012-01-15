#!/bin/bash

FILES=".bashmine.sh .zshmine.sh .gitconfig .vim .irbrc .screenrc"
for f in $FILES; do
	ln -s $PWD/$f $HOME/$f
done
ln -s $HOME/.vim/ian_vimrc $HOME/.vimrc

if [[ ! -x $HOME/.rvm ]]; then
	bash -s stable < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer )
fi
if [[ ! -x $HOME/.oh-my-zsh ]]; then
	wget --no-check-certificate https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh
fi

grep zshmine.sh $HOME/.zshrc > /dev/null
if [[ 0 -ne $? ]]; then
	echo '. $HOME/.zshmine.sh' >> ~/.zshrc
fi
grep bashmine.sh $HOME/.bashrc > /dev/null
if [[ 0 -ne $? ]]; then
	echo '. $HOME/.bashmine.sh' >> ~/.bashrc
fi
