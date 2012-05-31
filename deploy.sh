#!/bin/bash -x

# Link configurations files and scripts
for f in `ls -A configs`; do
    rm $HOME/$f
	ln -s $PWD/configs/$f $HOME/$f
done

# Install RVM
if [[ ! -x $HOME/.rvm ]]; then
	bash -s stable < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer )
fi
# Install Oh my ZSH
if [[ ! -x $HOME/.oh-my-zsh ]]; then
	wget --no-check-certificate https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh
fi

# Add autoload configs code
grep zshmine.sh $HOME/.zshrc > /dev/null
if [[ 0 -ne $? ]]; then
	echo '. $HOME/.zshmine.sh' >> ~/.zshrc
fi
grep bashmine.sh $HOME/.bashrc > /dev/null
if [[ 0 -ne $? ]]; then
	echo '. $HOME/.bashmine.sh' >> ~/.bashrc
fi
