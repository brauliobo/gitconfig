setxkbmap -model abnt2 -layout br -variant abnt2

if [ -f $HOME/.Xmodmap ]; then
  /usr/bin/xmodmap $HOME/.Xmodmap
fi

# disable beep
xset -b

