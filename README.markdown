These are configuration and script files for my personal use.

Altough general, it is highly focused on Rails development. This involve mainly
*   VIM as editor
*   git as SCM
*   RVM for ruby
*   ZSH for shell and Oh My ZSH as default settings

A `deploy.sh` script will symlink configurations, hooks and install RVM and Oh My ZSH.
It is very simple, just check its source code.

Install
=======
These are sort of mandatory steps:

1.  Install dependencies

        sudo apt-get install wget curl command-not-found vim

1.  Run `deploy.sh`
1.  Change `~/.gitconfig` with your name/email and commit changes

There are also some extra things you may like:

1.  `ack-grep` is used as the grep command in VIM. Just install `ack-grep` package
1.  Change to ZSH and OhMyZSH: `sudo apt-get install zsh` and `chsh -s /bin/zsh` (also check your terminal emulator - Konsole, Gnome Termimal, etc)
1.  `sshsudo` depends on `sshpass` package
1.  VIM support of X clipboard depends on `vim-gnome` package
1.  `git-new-workdir` is aliased to `/usr/share/doc/git/contrib/workdir/git-new-workdir`. So to use it run:

        sudo chmod +x /usr/share/doc/git/contrib/workdir/git-new-workdir

Perl development
----------------

1.  Install cpanminus with `curl -L http://cpanmin.us | perl - --sudo App::cpanminus`

Troubleshooting
===============

Submodules problem
------------------
Your submodule can't be updated: the easiest fix is to remove and get it again
    
    MODULE=configs/.vim rm -fr $MODULE && rm -fr .git/modules/$MODULE; g smuir

References
==========

*   Oh My ZSH http://railscasts.com/episodes/308-oh-my-zsh
