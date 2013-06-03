Install
=======
1.  Install dependencies

        sudo apt-get install wget curl zsh command-not-found vim ack-grep sshpass vim-gnome

2.  Run deploy.sh (your existings configs won't be overwritten)
3.  Change to ZSH: `chsh -s /bin/zsh` (also check your terminal emulator - Konsole, Gnome Termimal, etc)
4.  Change ~/.gitconfig with your name/email and commit changes

Troubleshooting
===============

Submodules problem
------------------
Your submodule can't be updated: the easiest fix is to remove and get it again
    
    MODULE=configs/.vim rm -fr $MODULE && rm -fr .git/modules/$MODULE; g smuir
