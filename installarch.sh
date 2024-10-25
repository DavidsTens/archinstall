#!/usr/bin/env bash

# Запрос данных для переменных
read -p "username (USER): " USER
read -p "hostname (HOST): " HOST
read -p "path to install (e.g., /dev/sda1): " PATH

pacman -Sy
pacman -S archlinux-keyring --no-confirm

mkfs.btrfs -L arch $PATH
mount $PATH /mnt

btrfs su cr /mnt/@
btrfs su cr /mnt/@home

umount -R /mnt

mount -o subvol=/@,noatime,compress=lzo $PATH /mnt
mkdir /mnt/home
mount -o subvol=/@home,noatime,compress=lzo $PATH /mnt/home

echo "liquorix"
pacman-key --keyserver hkps://keyserver.ubuntu.com --recv-keys 9AE4078033F8024D
pacman-key --lsign-key 9AE4078033F8024D

echo -e '\n[liquorix]\nServer = https://liquorix.net/archlinux/$repo/$arch' | sudo tee -a '/etc/pacman.conf' > /dev/null

echo "chaotic-aur"
pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
pacman-key --lsign-key 3056513887B78AEB

pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

echo -e '\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist' | sudo tee -a '/etc/pacman.conf' > /dev/null

sudo sed -i 's/^#*\(ParallelDownloads\s*=\s*\).*/\110/' /etc/pacman.conf

pacman -Sy

pacstrap /mnt base base-devel linux-lqx linux-lqx-headers linux-firmware networkmanager intel-ucode git nano curl wget zsh yay --no-confirm
genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt

echo "liquorix"
pacman-key --keyserver hkps://keyserver.ubuntu.com --recv-keys 9AE4078033F8024D
pacman-key --lsign-key 9AE4078033F8024D

echo -e '\n[liquorix]\nServer = https://liquorix.net/archlinux/$repo/$arch' | sudo tee -a '/etc/pacman.conf' > /dev/null

echo "chaotic-aur"
pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
pacman-key --lsign-key 3056513887B78AEB

pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

echo -e '\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist' | sudo tee -a '/etc/pacman.conf' > /dev/null

sed -i 's/^#*\(ParallelDownloads\s*=\s*\).*/\110/' /etc/pacman.conf

echo $HOST > /etc/hostname
echo -e "127.0.0.1 localhost\n::0 localhost\n127.0.0.1 $HOST" >> /etc/hosts

systemctl enable NetworkManager
systemctl mask NetworkManager-wait-online.service

ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
hwclock --systohc

sed -i "s/#en_US.UTF-8/en_US.UTF-8/g" /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

passwd

useradd -mG wheel -s /usr/bin/zsh $USER
passwd $USER
echo "$USER ALL=(ALL:ALL) ALL" >> /etc/sudoers
visudo -c

sudo pacman -Sy grub

grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

sudo pacman -S xfce4 xfce4-goodies lightdm lightdm-gtk-greeter xorg network-manager-applet --no-confirm --needed
exit
umount -R /mnt
