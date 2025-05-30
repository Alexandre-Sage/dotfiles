#!/bin/bash

if [ ! -e "/etc/fstab" ]; then
	echo "Error: /etc/fstab not found"
	exit 1
fi

SCRIPT_ABSOLUTE_DIR_PATH=$(pwd)
ZSH_PLUGINS_DIR=/usr/share/zsh/plugins
GIT_HUB_URL=https://github.com

user="arch-linux"
enable_docker=false
virtual_box=false
install_grub=false
groups="wheel,docker"
password="root"
while getopts "u:p:dvg" opt; do
  case "$opt" in
	u)
	  user="$OPTARG"
	  ;;
	p)
	  password="$OPTARG"
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

pacman -Syy
pacman -S --needed --noconfirm - < ./packages
if $virtual_box; then 
	pacman -S virtualbox-guest-utils --noconfirm
fi

if $install_grub; then 
  if $virtual_box; then 
	 grub-install --target="i386-pc" /dev/sda
  else
  	 grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --recheck
  fi
  sudo grub-mkconfig -o /boot/grub/grub.cfg
fi

echo "Set up zsh"

mkdir /usr/share/zsh/plugins
git clone https://github.com/zsh-users/zsh-autosuggestions.git  $ZSH_PLUGINS_DIR/zsh-autosuggestions 
git clone https://github.com/marlonrichert/zsh-autocomplete.git $ZSH_PLUGINS_DIR/zsh-autocomplete
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_PLUGINS_DIR/zsh-syntax-highlighting
git clone https://github.com/jeffreytse/zsh-vi-mode $ZSH_PLUGINS_DIR/zsh-vi-mode

chown -R :wheel $SCRIPT_ABSOLUTE_DIR_PATH

mkdir /root/.config /root/.xmonad

git clone https://github.com/Alexandre-Sage/nvim.git /root/.config/nvim
useradd -m -G $groups -s /bin/zsh -p $password $user
echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" | EDITOR="tee -a" visudo
echo "KEYMAP=fr" >> /etc/vconsole.conf

chsh -s /bin/zsh

ln -s $SCRIPT_ABSOLUTE_DIR_PATH/xmonad.hs /root/.xmonad/xmonad.hs
ln -s $SCRIPT_ABSOLUTE_DIR_PATH/.xinitrc /root/.xinitrc
ln -s $SCRIPT_ABSOLUTE_DIR_PATH/.zshrc /root/.zshrc 
ln -s $SCRIPT_ABSOLUTE_DIR_PATH/.Xresources /root/.Xresources 
ln -s $SCRIPT_ABSOLUTE_DIR_PATH/.fzfrc /root/.fzfrc

sudo systemctl enable  dhcpcd

if $virtual_box; then 
	systemctl enable vboxservice
	VBoxClient-all
fi

if $enable_docker; then
	echo "enable docker"
	sudo systemctl enable  docker
fi 
