#!/bin/bash

EDITOR=vi

ROOTDEV=/dev/sda4
ROOTLABEL=LINUX
#HOMEDEV=/dev/sda6
GRUBDEV=/dev/sda
HOSTNAME=bhavaintelnuc
TZ=America/Bahia
LCENC=UTF-8
LCLANG=pt_BR
LANG=$LCENC.$LCLANG
KEYMAP=br-latin1-abnt2
FONT=lat2-16

USER=braulio

#WIFIMOD=ath9k
WIFIESSID=OpenWrt

s_run() {
  echo '=== outside chroot'; read
  set -x
  echo '== setup wireless'; s_wifi
  echo '== load keymap'; s_keymap
  echo '== root fs'; s_fs
  echo '== enable multilib and set mirrors'; read; s_sync
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

s_sync() {
  $EDITOR /etc/pacman.conf
  $EDITOR /etc/pacman.d/mirrorlist
}

s_install() {
  pacstrap /mnt base
  genfstab -p /mnt >> /mnt/etc/fstab
}

### functions for chroot

s_system() {
  echo $HOSTNAME > /etc/hostname
  ln -sf /usr/share/zoneinfo/$TZ /etc/localtime
  $EDITOR /etc/locale.gen
  echo LANG=$LANG > /etc/locale.conf
  locale-gen

  pacman -S btrfs-progs grub os-prober
  mkinitcpio -p linux

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
  pacman -S iw wireless_tools net-tools
  pacman -S ssh rsync zsh tmux

  pacman -S sudo vim git wget pkgfile
  pkgfile --update

  pacman -S pavucontrol alsa-utils pulseaudio
  pacman -S xorg sddm
  pacman -S plasma breeze-kde4 konsole kate kmix lib32-sni-qt sni-qt
  pacman -S firefox chromium

  systemctl enable sddm
  systemctl enable NetworkManager
  systemctl enable sshd
}

#s_run
#s_chroot_run
