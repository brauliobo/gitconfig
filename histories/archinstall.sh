#!/bin/bash

EDITOR=vi

ARCH=x86_64
ROOTDEV=/dev/sda4
ROOTLABEL=LINUX
#HOMEDEV=/dev/sda6
GRUBDEV=/dev/sda
HOSTNAME=bhavaintelnuc
TZ=America/Bahia
LCLANG=pt_BR
LCENC=UTF-8
PACKAGELOCALE1=pt-br
PACKAGELOCALE2=pt_br
LANG=$LCLANG.$LCENC
KEYMAP=br-latin1-abnt2
FONT=default8x16

USER=braulio

#WIFIMOD=ath9k
WIFIESSID=OpenWrt

s_run() {
  echo '=== outside chroot'; read
  set -x
  echo '== setup wireless'; s_wifi
  echo '== load keymap'; s_keymap
  echo '== root fs'; s_fs
  echo '== install'; s_install
}

s_chroot_run() {
  arch-chroot /mnt <<'EOC'
    set -x
    echo '=== inside chroot'; read
    `declare -f s_system s_auth s_desktop`
    echo '== system setup'; read; s_system
    echo '== users setup'; s_auth
    echo '== basic desktop install'; s_desktop
EOC
}

s_wifi() {
  if [[ -n $WIFIMOD ]]; then
    modprobe $WIFIMOD
    ifconfig wlp2s0 up
    kiwconfig wlp2s0 essid $WIFIESSID
    dhclient wlp2s0
  fi
}

s_keymap() {
  loadkeys $KEYMAP
}

s_fs() {
  #mkfs.btrfs $ROOTDEV -f -L $ROOTLABEL
  mount $ROOTDEV /mnt
  mkdir /mnt/home
  if [[ -n $HOMEDEV ]]; then
    mount $HOMEDEV /mnt/home
  fi
}

s_install() {
  $EDITOR /etc/pacman.d/mirrorlist
  pacstrap /mnt base
  genfstab -p /mnt >> /mnt/etc/fstab
}

### functions for chroot

s_system() {
  $EDITOR /etc/pacman.conf
  pacman -Syu

  echo $HOSTNAME > /etc/hostname
  ln -sf /usr/share/zoneinfo/$TZ /etc/localtime
  echo $TZ > /etc/timezone
  $EDITOR /etc/locale.gen
  echo LANG=$LANG > /etc/locale.conf
  locale-gen

  pacman -S btrfs-progs
  $EDITOR /etc/mkinitcpio.conf
  mkinitcpio -p linux

  pacman -S grub os-prober
  grub-install --target=i386-pc --recheck --debug $GRUBDEV
  grub-mkconfig -o /boot/grub/grub.cfg
  echo -e "KEYMAP=$KEYMAP\nFONT=$FONT" > /etc/vconsole.conf
}

s_auth() {
  echo '== root password'; read
  passwd
  echo '== user password'; read
  pacman -S sudo
  useradd $USER -m
  passwd $USER
  vi /etc/sudoers
  usermod -aG wheel $USER
}

s_desktop() {
  pacman -S iw wireless_tools net-tools networkmanager
  pacman -S openssh rsync zsh tmux htop

  pacman -S sudo vim git wget pkgfile
  pkgfile --update

  pacman -S pavucontrol alsa-utils pulseaudio
  pacman -S xf86-input-synaptics kcm-touchpad-frameworks
  udo cp /usr/share/X11/xorg.conf.d/50-synaptics.conf /etc/X11/xorg.conf.d
  pacman -S java-runtime
  pacman -S xorg lightdm

  systemctl enable sshd
  systemctl enable lightdm
  systemctl enable NetworkManager

  pacmas -S breeze-kde4 qtcurve-gtk2
  pacman -S plasma konsole kate kmix lib32-sni-qt sni-qt kdeutils kdegraphics kdebase-dolphin
  pacman -S firefox chromium
  pacman -S mplayer vlc
  pacman -S libreoffice-fresh
  pacman -S java-runtime
  #yaourt libappindicator

  pacman -S firefox-i18n-$PACKAGELOCALE1 kde-l10n-$PACKAGELOCALE2  libreoffice-fresh-pt-BR

  pacman -S konversation skype

  pacman -S owncloud-client ktorrent

  # noosfero
  pacman -S postgresql imagemagick po4a
  yaourt tango-icon-theme
  pacman -S apache nginx

  # dev
  pacman -S ack the_silver_searcher

  s_yaourt
}

s_yaourt() {
  echo "[archlinuxfr]
  SigLevel = Never
  Server = http://repo.archlinux.fr/$ARCH" >> /etc/pacman.conf
  pacman -Sy base-devel yaourt
  yaourt ttf-ms-fonts
  yaourt chromium-pepper-flash
}

#s_run
#s_chroot_run
