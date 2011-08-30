#!/bin/bash

FILES=".bashmine.sh .gitconfig .vim"

for f in $FILES; do
	ln -s $PWD/$f $HOME/$f
done
ln -s $HOME/.vim/ian_vimrc $HOME/.vimrc

echo '. .bashmine.sh' >> ~/.bashrc
