#!/bin/bash

ischroot=0

if [ $ischroot -eq 0 ]
then

cat << _EOF_ > create.disks
label: dos
label-id: 0xbe58cb3b
device: /dev/sda
unit: sectors
/dev/sda1 : start=        2048, size=      409600, type=83, bootable
/dev/sda2 : start=      411648, size=     8388608, type=82
/dev/sda3 : start=     8800256, size=   200914911, type=83
_EOF_

	sfdisk /dev/sda < create.disks

	mkfs.ext2 /dev/sda1
	mkfs.ext4 /dev/sda3

	mkswap /dev/sda2
	swapon /dev/sda2

	mount /dev/sda3 /mnt
	mkdir /mnt/boot
	mount /dev/sda1 /mnt/boot

	pacstrap -i /mnt base base-devel --noconfirm

	genfstab -U -p /mnt >> /mnt/etc/fstab

	sed -i 's/ischroot=0/ischroot=1/' ./install_arch.sh
	cp ./install_arch.sh /mnt/install_arch.sh

	arch-chroot /mnt /bin/bash -x << _EOF_
sh /install_arch.sh
_EOF_

fi

if [ $ischroot -eq 1 ]
then

	pacman -Sy
	pacman -S vim sudo grub-bios --noconfirm

	sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen

	locale-gen

	echo LANG=en_US.UTF-8 > /etc/locale.conf

	ln -s /usr/share/zoneinfo/Europe/Moscow /etc/localtime

	hwclock --systohc --utc

	echo lnx > /etc/hostname
	# todo use variable for user
	useradd -m -g users -G wheel,video -s /bin/bash user
	
	sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
	sed -i 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

	grub-install --recheck /dev/sda
	grub-mkconfig -o /boot/grub/grub.cfg

	sed -i 's/#Color/Color/' /etc/pacman.conf

	pacman -S bash-completion xorg-server xorg-apps xorg-xinit mesa xorg-twm xterm xorg-xclock xf86-input-synaptics virtualbox-guest-utils linux-headers --noconfirm

	modprobe -a vboxguest vboxsf vboxvideo

	cp /etc/X11/xinit/xinitrc /home/user/.xinitrc
	echo -e "\nvboxguest\nvboxsf\nvboxvideo" >> /home/user/.xinitrc

	sed -i 's/#!\/bin\/sh/#!\/bin\/sh\n\/usr\/bin\/VBoxClient-all/' /home/user/.xinitrc

	pacman -S cinnamon nemo-fileroller gdm --noconfirm

	mv /usr/share/xsessions/gnome.desktop ~/

	systemctl enable gdm

	pacman -S net-tools network-manager-applet --noconfirm

	systemctl enable NetworkManager

	pacman -S gedit gnome-terminal pulseaudio pulseaudio-alsa pavucontrol firefox vlc eog eog-plugins chromium unzip unrar p7zip pidgin toxcore deluge smplayer audacious qmmp gimp xfburn thunderbird gnome-system-monitor doublecmd-gtk2 gnome-calculator pinta recoll deadbeef veracrypt bleachbit gnome-screenshot evince mlocate antiword catdoc unrtf djvulibre id3lib mutagen python2-pychm aspell-en git calibre ttf-freefont ttf-linux-libertine libreoffice-fresh libreoffice-fresh-ru --noconfirm

	curl -O https://blackarch.org/strap.sh
	bash ./strap.sh
	pacman -Syyu	
	pacman -Ss blackarch-mirrorlist
fi


arch-chroot /mnt /bin/bash -x << _EOF_
passwd
1
1
_EOF_

arch-chroot /mnt /bin/bash -x << _EOF_
passwd user
2
2
_EOF_

umount -R /mnt/boot
umount -R /mnt
reboot
