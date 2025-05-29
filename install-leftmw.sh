SCRIPT_ABSOLUTE_DIR_PATH=$(pwd)

yay -S leftwm leftwm-config leftwm-theme-git lemonbar-xft-git --noconfirm

ln -S $SCRIPT_ABSOLUTE_DIR_PATH/leftwm /home/$USER/.config/leftwm
leftwm-theme apply "perso"
