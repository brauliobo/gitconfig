if [ -f $HOME/.Xmodmap ]; then
  /usr/bin/xmodmap $HOME/.Xmodmap
fi

# disable beep
xset -b
