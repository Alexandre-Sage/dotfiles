#!/bin/bash

SCRIPT_ABSOLUTE_DIR_PATH=$(pwd)
ZSH_PLUGINS_DIR=/usr/share/zsh/plugins
GIT_HUB_URL=https://github.com
source "$SCRIPT_ABSOLUTE_DIR_PATH/helpers/log.sh"

show_help() {
	cat << EOF
Usage: $(basename "$0") [OPTIONS]

Root installation script for Arch Linux system setup.

OPTIONS:
    -u USERNAME    Set username for new user (default: arch-linux)
    -p PASSWORD    Set password for new user (default: root)
    -d             Enable Docker service
    -v             Install VirtualBox guest utilities and add vboxsf group
    -q             Configure for QEMU environment (uses /dev/vda for GRUB)
    -g             Install and configure GRUB bootloader
    -h             Display this help message

EXAMPLES:
    $(basename "$0") -u myuser -p mypass -d -g
        Create user 'myuser' with password 'mypass', enable Docker, install GRUB
    
    $(basename "$0") -v -g
        Install with VirtualBox support and GRUB
    
    $(basename "$0") -q -g
        Install with QEMU support and GRUB

EOF
}


log "Starting root installation script"

if [ ! -e "/etc/fstab" ]; then
	error "/etc/fstab not found"
fi


user="arch-linux"
enable_docker=false
virtual_box=false
install_grub=false
groups="wheel,docker"
password="root"
qemu=false

while getopts "u:p:dvqgh" opt; do
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
	q)
		qemu=true
		;;
	g) 
	  install_grub=true
	  ;;
	h)
	  show_help
	  exit 0
	  ;;
	*)
	  show_help
	  exit 1
	  ;;
  esac
done


install_packages() {
	log "Installing packages..."
	pacman -Syy || error "Failed to sync package databases"
	pacman -S --needed --noconfirm - < ./packages \
		|| error "Failed to install packages from ./packages"
	
	if $virtual_box; then
		log "Installing VirtualBox guest utilities..."
		pacman -S virtualbox-guest-utils --noconfirm \
			|| error "Failed to install VirtualBox guest utilities"
	fi
	log "Package installation completed successfully"
}

configure_grub() {
	if $install_grub; then
		log "Configuring GRUB bootloader..."
		if $virtual_box; then
			log "Installing GRUB for VirtualBox (i386-pc, /dev/sda)"
			grub-install --target="i386-pc" /dev/sda \
				|| error "Failed to install GRUB for VirtualBox"
		elif $qemu; then
			log "Installing GRUB for QEMU (i386-pc, /dev/vda)"
			grub-install --target="i386-pc" /dev/vda \
				|| error "Failed to install GRUB for QEMU"
		else
			log "Installing GRUB for UEFI (x86_64-efi)"
			grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --recheck \
				|| error "Failed to install GRUB for UEFI"
		fi
		log "Generating GRUB configuration..."
		sudo grub-mkconfig -o /boot/grub/grub.cfg \
			|| error "Failed to generate GRUB configuration"
		log "GRUB configuration completed"
	else
		log "Skipping GRUB installation (not requested)"
	fi
}

configure_zsh() {
	log "Configuring ZSH and plugins..."
	
	mkdir -p /usr/share/zsh/plugins \
		|| error "Failed to create ZSH plugins directory"
	
	log "Cloning ZSH plugins..."
	git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_PLUGINS_DIR/zsh-autosuggestions \
		|| warning "Failed to clone zsh-autosuggestions"

	git clone https://github.com/marlonrichert/zsh-autocomplete.git $ZSH_PLUGINS_DIR/zsh-autocomplete \
		|| warning "Failed to clone zsh-autocomplete"

	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_PLUGINS_DIR/zsh-syntax-highlighting \
		|| warning "Failed to clone zsh-syntax-highlighting"

	git clone https://github.com/jeffreytse/zsh-vi-mode $ZSH_PLUGINS_DIR/zsh-vi-mode \
		|| warning "Failed to clone zsh-vi-mode"

	log "Creating ZSH symlinks for root user..."
	ln -sf $SCRIPT_ABSOLUTE_DIR_PATH/config-files/.zshrc /root/.zshrc || error "Failed to create .zshrc symlink"
	
	log "Setting ZSH as default shell for root..."
	chsh -s /bin/zsh || error "Failed to change shell to ZSH"
	
	log "ZSH configuration completed"
}

configure_groups_and_permissions() {
	log "Configuring groups and permissions..."
	
	log "Setting wheel group ownership for $SCRIPT_ABSOLUTE_DIR_PATH"
	chown -R :wheel $SCRIPT_ABSOLUTE_DIR_PATH \
		|| warning "Failed to change ownership to wheel group"

	log "Creating root config directory..."
	mkdir -p /root/.config \
		|| error "Failed to create /root/.config directory"
	# git clone https://github.com/Alexandre-Sage/nvim.git /root/.config/nvim

	log "Creating user '$user' with groups: $groups"
	useradd -m -G $groups -s /bin/zsh -p $password $user \
		|| error "Failed to create user $user"
	
	log "Configuring sudo permissions for wheel group..."
	echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" | EDITOR="tee -a" visudo \
		|| error "Failed to configure sudo permissions"
	
	log "Setting keyboard layout to French (fr)..."
	echo "KEYMAP=fr" >> /etc/vconsole.conf \
		|| warning "Failed to set KEYMAP in vconsole.conf"
	
	log "Groups and permissions configured successfully"
}

set_up_config_files() {
	log "Setting up configuration file symlinks for root..."
	
	ln -sf $SCRIPT_ABSOLUTE_DIR_PATH/config-files/.xinitrc /root/.xinitrc \
		|| warning "Failed to create .xinitrc symlink"

	ln -sf $SCRIPT_ABSOLUTE_DIR_PATH/config-files/.Xresources /root/.Xresources \
		|| warning "Failed to create .Xresources symlink"

	ln -sf $SCRIPT_ABSOLUTE_DIR_PATH/config-files/.fzfrc /root/.fzfrc \
		|| warning "Failed to create .fzfrc symlink"
	
	log "Configuration files symlinked successfully"
}

enable_systems(){
	log "Enabling system services..."
	
	log "Enabling dhcpcd service..."
	sudo systemctl enable dhcpcd \
		|| error "Failed to enable dhcpcd service"
	
	if $virtual_box; then
		log "Enabling VirtualBox services..."
		systemctl enable vboxservice \
			|| error "Failed to enable vboxservice"

		VBoxClient-all \
			|| warning "Failed to start VBoxClient-all"
	fi
	
	if $enable_docker; then
		log "Enabling Docker service..."
		sudo systemctl enable docker \
			|| error "Failed to enable Docker service"
	fi
	
	log "System services enabled successfully"
}

main() {
	log "=== Starting Arch Linux Root Installation ==="
	log "Configuration:\n  user=$user\n  docker=$enable_docker\n  virtualbox=$virtual_box\n  qemu=$qemu\n  grub=$install_grub"

	install_packages
	configure_grub
	configure_zsh
	configure_groups_and_permissions
	set_up_config_files
	enable_systems
	
	log "=== Root installation completed successfully ==="
	log "Log file saved to: $LOG_FILE"
}

main


