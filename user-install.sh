#!/bin/bash
SCRIPT_ABSOLUTE_DIR_PATH=$(pwd)
git_mail="your_email@example.com"
if [ -z "$1" ];then 
	git_mail=$1
fi


mkdir /home/$USER/AUR 
mkdir /home/$USER/project 
mkdir /home/$USER/workspace 
mkdir /home/$USER/.config 
mkdir /home/$USER/.local
mkdir /home/$USER/.xmonad

ln -s $SCRIPT_ABSOLUTE_DIR_PATH/xmonad.hs /home/$USER/.xmonad/xmonad.hs
ln -s $SCRIPT_ABSOLUTE_DIR_PATH/.xinit /home/$USER/.xinit
ln -s $SCRIPT_ABSOLUTE_DIR_PATH/.zshrc /home/$USER/.zshrc 
ln -s $SCRIPT_ABSOLUTE_DIR_PATH/picom /home/$USER/.config/picom


git clone https://aur.archlinux.org/yay.git ~/AUR 
cd ~/AUR/yay && makepkg -si --noconfirm
yay -S spotify ranger

git clone https://github.com/Alexandre-Sage/nvim.git /home/$USER/.config/nvim

if $install_node; then
	echo "Set up node packages"
	npm i -g pnpm yarn bun typescript turbo tsup ts-node
fi
if $install_rust; then
  	echo "Set up rust"
	rustup default stable
fi

ssh-keygen -t ed25519 -C $git_mail -P "" -f /home/$USER/.ssh/git_key
eval "$(ssh-agent -s)"
ssh-add /home/$USER/id_ed25519

passwd $USER
