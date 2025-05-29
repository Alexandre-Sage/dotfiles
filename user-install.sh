#!/bin/bash
SCRIPT_ABSOLUTE_DIR_PATH=$(pwd)
NATS_TOKEN=$(openssl rand -base64 16)
REDIS_TOKEN=$(openssl rand -base64 16)
git_mail="your_email@example.com"


while getopts "m:l" opt; do
  case "$opt" in
	m)
	  git_mail="$OPTARG"
	  ;;
	l)
	  $SCRIPT_ABSOLUTE_DIR_PATH/install-leftmw.sh
	;;
  esac
done



mkdir /home/$USER/AUR 
mkdir /home/$USER/project 
mkdir /home/$USER/workspace 
mkdir /home/$USER/.config 
mkdir /home/$USER/.local
# mkdir /home/$USER/.xmonad
mkdir /home/$USER/.ssh
mkdir /home/$USER/.config/terminator
mkdir /home/$USER/.config/leftwm
mkdir /home/$USER/.config/gtk-3.0

# ln -s $SCRIPT_ABSOLUTE_DIR_PATH/xmonad.hs /home/$USER/.xmonad/xmonad.hs
ln -s $SCRIPT_ABSOLUTE_DIR_PATH/.xinitrc /home/$USER/.xinitrc
ln -s $SCRIPT_ABSOLUTE_DIR_PATH/.zshrc /home/$USER/.zshrc 
ln -s $SCRIPT_ABSOLUTE_DIR_PATH/prompt.sh /home/$USER/prompt.sh 
ln -s $SCRIPT_ABSOLUTE_DIR_PATH/picom /home/$USER/.config/picom
ln -s $SCRIPT_ABSOLUTE_DIR_PATH/wallpaper /home/$USER/.local/wallpaper
ln -s $SCRIPT_ABSOLUTE_DIR_PATH/.Xresources /home/$USER/.Xresources 
ln -s $SCRIPT_ABSOLUTE_DIR_PATH/.fzfrc /home/$USER/.fzfrc
ln -s $SCRIPT_ABSOLUTE_DIR_PATH/terminator/config /home/$USER/.config/terminator/config
ln -s $SCRIPT_ABSOLUTE_DIR_PATH/gtk.css /home/$USER/.config/gtk-3.0/gtk.css
ln -s $SCRIPT_ABSOLUTE_DIR_PATH/.sqlfluff /home/$USER/.sqlfluff

git clone https://aur.archlinux.org/yay.git ~/AUR/yay
cd ~/AUR/yay && makepkg -si --noconfirm
yay -S spotify ranger fastfetch natscli --noconfirm


ssh-keygen -t ed25519 -C $git_mail -P "" -f /home/$USER/.ssh/id_ed25519
eval "$(ssh-agent -s)"
ssh-add /home/$USER/.ssh/id_ed25519

# curl --silent https://api.github.com/meta \
#   | jq --raw-output '"github.com "+.ssh_keys[]' >> ~/.ssh/known_hosts

git clone https://github.com/Alexandre-Sage/nvim.git /home/$USER/.config/nvim

# echo "Set up node packages"
# sudo npm i -g pnpm yarn bun typescript turbo tsup ts-node prettier @fsouza/prettierd
# echo "Set up rust"
# rustup default stable

touch  ~/.local/.local-infra-env
echo -e "export LOCAL_NATS_TOKEN=\"$NATS_TOKEN\"" > ~/.local/.local-infra-env
echo -e "export LOCAL_REDIS_TOKEN=\"$REDIS_TOKEN\"" >> ~/.local/.local-infra-env

if pacman -Q virtualbox-guest-utils &>/dev/null; then
	VBoxClient-all
fi
