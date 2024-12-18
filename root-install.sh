#!/bin/bash
user="arch-linux"
install_node=false
install_rust=false
enable_docker=false
virtual_box=false
install_grub=false
groups="wheel,docker"
while getopts "u:r:n:d:v" opt; do
  case "$opt" in
	u)
	  user="$OPTARG"
	  ;;
	r)
	  install_rust=true
	  ;;
	n)
	  install_node=true
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

useradd -m -G $groups -s /bin/zsh $user

ln -s ./.xmonad ~/.xmonad
ln -s ./.xinit ~/.xinit
ln -s ./.zshrc ~/.zshrc 
ln -s ./.xmonad /home/$user/.xmonad
ln -s ./.xinit /home/$user/.xinit
ln -s ./.zshrc /home/$user/.zshrc 



sudo systemctl enable --now dhcpcd

if $enable_docker; then
	echo "enable docker"
	sudo systemctl enable --now docker
fi 
