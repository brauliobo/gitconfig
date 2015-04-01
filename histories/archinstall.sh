ROOTDEV=/dev/sda5
ROOTLABEL=LINUX
HOMEDEV=/dev/sda6
GRUBDEV=/dev/sda
HOSTNAME=laptop
TZ=America/Bahia
LANG=pt_BR.UTF-8
KEYMAP=br-latin1-us
FONT=lat2-16

echo '== outside chroot'
modprobe ath9k
ifconfig wlp2s0 up
iwconfig wlp2s0 essid OpenWrt
dhclient wlp2s0
loadkeys $KEYMAP

#mkfs.btrfs $ROOTDEV -f -L $ROOTLABEL
mount $ROOTDEV /mnt
mkdir /mnt/home
mount $HOMEDEV /mnt/home

vi /etc/pacman.d/mirrorlist
pacstrap /mnt base
genfstab -p /mnt >> /mnt/etc/fstab

echo '== inside chroot'
arch-chroot /mnt
echo $HOSTNAME > /etc/hostname
ln -sf /usr/share/zoneinfo/$TZ /etc/localtime
nano /etc/locale.gen
echo LANG=$LANG > /etc/locale.conf
locale-gen
mkinitcpio -p linux
passwd
pacman -S grub os-prober
grub-install --target=i386-pc --recheck --debug $GRUBDEV
grub-mkconfig -o /boot/grub/grub.cfg
echo -e "KEYMAP=$KEYMAP\nFONT=$FONT" > /etc/vconsole.conf

pacmac -S btrfs-progs
pacmac -S plasma breeze-kde4

