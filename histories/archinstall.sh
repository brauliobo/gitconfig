ROOTDEV=/dev/sda5
ROOTLABEL=LINUX
HOMEDEV=/dev/sda6
GRUBDEV=/dev/sda
HOSTNAME=laptop
TZ=America/Bahia
LANG=pt_BR.UTF-8
KEYMAP=br-latin1-abnt2
FONT=lat2-16

USER=braulio

WIFIMOD=ath9k
WIFIESSID=OpenWrt

echo '=== outside chroot'; read
set -x

echo '== setup wireless'
modprobe $WIFIMOD
ifconfig wlp2s0 up
iwconfig wlp2s0 essid $WIFIESSID
dhclient wlp2s0

echo '== load keymap'
loadkeys $KEYMAP

echo '== root fs'
#mkfs.btrfs $ROOTDEV -f -L $ROOTLABEL
mount $ROOTDEV /mnt
mkdir /mnt/home
mount $HOMEDEV /mnt/home

echo '== enable multilib and set mirrors'; read
vi /etc/pacman.conf
vi /etc/pacman.d/mirrorlist

echo '== install'
pacstrap /mnt base
genfstab -p /mnt >> /mnt/etc/fstab

echo '=== inside chroot'; read
set -x

arch-chroot /mnt
echo $HOSTNAME > /etc/hostname
ln -sf /usr/share/zoneinfo/$TZ /etc/localtime
nano /etc/locale.gen
echo LANG=$LANG > /etc/locale.conf
locale-gen
mkinitcpio -p linux
pacman -S grub os-prober
grub-install --target=i386-pc --recheck --debug $GRUBDEV
grub-mkconfig -o /boot/grub/grub.cfg
echo -e "KEYMAP=$KEYMAP\nFONT=$FONT" > /etc/vconsole.conf

echo '== root password'; read
passwd
echo '== user password'; read
useradd $USER -m
usermod -aG sudo $USER
passwd $USER

echo '== basic desktop install'; read
pacman -S btrfs-progs
pacman -S iw wireless_tools net-tools

pacman -S sudo vim git wget pkgfile
pkgfile --update

pacman -S pavucontrol alsa-utils
pacman -S xorg sddm
pacman -S plasma breeze-kde4 konsole kate

systemctl enable sddm
systemctl enable NetworkManager

