#!/bin/bash

mkdir ~/AUR ~/project ~/workspace

git clone https://aur.archlinux.org/yay.git ~/AUR 
cd ~/AUR/yay && makepkg -si --noconfirm
yay -S spotify 

if $install_node; then
	echo "Set up node packages"
	npm i -g pnpm yarn bun typescript turbo tsup ts-node
fi
if $install_rust; then
  	echo "Set up rust"
	rustup default stable
fi
