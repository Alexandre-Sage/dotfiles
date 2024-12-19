#!/bin/bash

if [ ! -e "/etc/fstab" ]; then
	echo "Error: /etc/fstab not found"
	exit 1
fi

user="arch-linux"
enable_docker=false
virtual_box=false
install_grub=false
groups="wheel,docker"
while getopts "u:r:n:d:v" opt; do
  case "$opt" in
	u)
	  user="$OPTARG"
	  ;;
	d)
      	  enable_docker=true
      	  ;;
	v) 
	  virtual_box=true
	  groups+=",vboxsf"
	  ;;
	g) 
	  install_grub=true
	  ;;
  esac
done



sudo pacman -Syy
sudo pacman -S --needed --noconfirm - < ./packages
if $virtual_box; then 
	pacman -S virtualbox-guest-utils
	VBoxClient-all
fi

if $install_grub; then 
  if $virtual_box; then 
	 grub-install --target="i386-pc" /dev/sda
  else
  	 grub-install --target=x86_64-efi --efi-directory=/mnt/boot/efi --bootloader-id=GRUB --recheck
  fi
  sudo grub-mkconfig -o /boot/grub/grub.cfg
fi

echo "Set up zsh"

mkdir /usr/share/zsh/plugins
git clone https://github.com/zsh-users/zsh-autosuggestions.git  /usr/share/zsh/plugins/zsh-autosuggestions 
git clone https://github.com/marlonrichert/zsh-autocomplete.git /usr/share/zsh/plugins/zsh-autocomplete
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /usr/share/zsh/plugins/zsh-syntax-highlighting

setfacl -m g:wheel:rwx ./

mkdir /root/.config /root/.xmonad

git clone https://github.com/Alexandre-Sage/nvim.git /root/.config/nvim
useradd -m -G $groups -s /bin/zsh $user

ln -s ./xmonad.hs /root/.xmonad/xmonad.hs
ln -s ./.xinit /root/.xinit
ln -s ./.zshrc /root/.zshrc 



sudo systemctl enable  dhcpcd

if $enable_docker; then
	echo "enable docker"
	sudo systemctl enable  docker
fi 
