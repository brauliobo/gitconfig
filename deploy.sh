#!/bin/bash

FILES=".bashmine.sh .gitconfig .vim .gemrc .irbrc .screenrc"

for f in $FILES; do
	ln -s $PWD/$f $HOME/$f
done
ln -s $HOME/.vim/ian_vimrc $HOME/.vimrc

echo '. $HOME/.bashmine.sh' >> ~/.bashrc
