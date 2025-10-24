#!/bin/bash

SCRIPT_ABSOLUTE_DIR_PATH=$(pwd)
source "$SCRIPT_ABSOLUTE_DIR_PATH/helpers/log.sh"

show_help() {
	cat << EOF
Usage: $(basename "$0") [OPTIONS]

User installation script for Arch Linux user environment setup.

OPTIONS:
    -m EMAIL       Set git email address (default: your_email@example.com)
    -l             Install LeftWM window manager
    -h             Display this help message

EXAMPLES:
    $(basename "$0") -m user@example.com -l
        Set git email and install LeftWM
    
    $(basename "$0") -m user@example.com
        Set git email without installing LeftWM

EOF
}

NATS_TOKEN=$(openssl rand -base64 16)
REDIS_TOKEN=$(openssl rand -base64 16)
INSTALL_LEFT=false
git_mail="your_email@example.com"


while getopts "m:lh" opt; do
  case "$opt" in
	m)
	  git_mail="$OPTARG"
	  ;;
	l)
	  INSTALL_LEFT=true
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

log "Starting user installation script"

set_up_home_dir(){
	log "Setting up home directory structure..."
	
	mkdir -p $HOME/AUR \
		|| error "Failed to create $HOME/AUR"

	mkdir -p $HOME/project \
		|| error "Failed to create $HOME/project"

	mkdir -p $HOME/workspace \
		|| error "Failed to create $HOME/workspace"

	mkdir -p $HOME/.config \
		|| error "Failed to create $HOME/.config"

	mkdir -p $HOME/.local \
		|| error "Failed to create $HOME/.local"

	mkdir -p $HOME/.ssh \
		|| error "Failed to create $HOME/.ssh"

	mkdir -p $HOME/.config/terminator \
		|| error "Failed to create $HOME/.config/terminator"

	mkdir -p $HOME/.config/leftwm \
		|| error "Failed to create $HOME/.config/leftwm"

	mkdir -p $HOME/.config/gtk-3.0 \
		|| error "Failed to create $HOME/.config/gtk-3.0"

	log "Home directory structure created successfully"
}

set_up_configuration_files(){
	log "Setting up configuration file symlinks..."
	
	ln -sf $SCRIPT_ABSOLUTE_DIR_PATH/.xinitrc $HOME/.xinitrc \
		|| warning "Failed to create .xinitrc symlink"

	ln -sf $SCRIPT_ABSOLUTE_DIR_PATH/.alacritty.toml $HOME/.alacritty.toml \
		|| warning "Failed to create .alacritty.toml symlink"

	ln -sf $SCRIPT_ABSOLUTE_DIR_PATH/.zshrc $HOME/.zshrc \
		|| warning "Failed to create .zshrc symlink"

	ln -sf $SCRIPT_ABSOLUTE_DIR_PATH/prompt.sh $HOME/prompt.sh \
		|| warning "Failed to create prompt.sh symlink"

	ln -sf $SCRIPT_ABSOLUTE_DIR_PATH/picom $HOME/.config/picom \
		|| warning "Failed to create picom symlink"

	ln -sf $SCRIPT_ABSOLUTE_DIR_PATH/wallpaper $HOME/.local/wallpaper \
		|| warning "Failed to create wallpaper symlink"

	ln -sf $SCRIPT_ABSOLUTE_DIR_PATH/.Xresources $HOME/.Xresources \
		|| warning "Failed to create .Xresources symlink"

	ln -sf $SCRIPT_ABSOLUTE_DIR_PATH/.fzfrc $HOME/.fzfrc \
		|| warning "Failed to create .fzfrc symlink"

	ln -sf $SCRIPT_ABSOLUTE_DIR_PATH/terminator/config $HOME/.config/terminator/config \
		|| warning "Failed to create terminator config symlink"

	ln -sf $SCRIPT_ABSOLUTE_DIR_PATH/gtk.css $HOME/.config/gtk-3.0/gtk.css \
		|| warning "Failed to create gtk.css symlink"

	ln -sf $SCRIPT_ABSOLUTE_DIR_PATH/.sqlfluff $HOME/.sqlfluff \
		|| warning "Failed to create .sqlfluff symlink"
	
	log "Cloning neovim configuration..."
	git clone https://github.com/Alexandre-Sage/nvim.git $HOME/.config/nvim \
		|| warning "Failed to clone nvim config (may already exist)"
	
	log "Configuration files setup completed"
}

install_aur_packages(){
	log "Installing AUR helper (yay)..."
	
	if [ -d "$HOME/AUR/yay" ]; then
		warning "yay directory already exists, skipping clone"
	else
		git clone https://aur.archlinux.org/yay.git ~/AUR/yay \
			|| error "Failed to clone yay from AUR"
	fi
	
	log "Building and installing yay..."
	(cd ~/AUR/yay && makepkg -si --noconfirm) \
		|| error "Failed to build/install yay"
	
	log "Installing AUR packages (spotify, ranger, fastfetch, natscli)..."
	yay -S spotify ranger fastfetch natscli --noconfirm \
		|| error "Failed to install AUR packages"
	
	log "AUR packages installed successfully"
}

install_gui(){
	if [ "$INSTALL_LEFT" = true ]; then
		log "Installing LeftWM window manager..."
		$SCRIPT_ABSOLUTE_DIR_PATH/install-leftmw.sh \
			|| error "Failed to install LeftWM"

		log "LeftWM installation completed"
	else
		log "Skipping LeftWM installation (not requested)"
	fi
}

configure_ssh_and_git(){
	log "Configuring SSH and Git..."
	log "Git email: $git_mail"
	
	if [ -f "$HOME/.ssh/id_ed25519" ]; then
		warning "SSH key already exists, skipping key generation"
	else
		log "Generating SSH key (ed25519)..."
		ssh-keygen -t ed25519 -C $git_mail -P "" -f $HOME/.ssh/id_ed25519 || error "Failed to generate SSH key"
	fi
	
	log "Starting SSH agent..."
	eval "$(ssh-agent -s)" \
		|| warning "Failed to start SSH agent"
	
	log "Adding SSH key to agent..."
	ssh-add $HOME/.ssh/id_ed25519 \
		|| warning "Failed to add SSH key to agent"
	
	log "SSH and Git configuration completed"
}

additional() {
	log "Setting up additional configurations..."
	
	log "Creating local infrastructure environment file..."
	touch ~/.local/.local-infra-env \
		|| error "Failed to create .local-infra-env"

	echo -e "export LOCAL_NATS_TOKEN=\"$NATS_TOKEN\"" > ~/.local/.local-infra-env
	echo -e "export LOCAL_REDIS_TOKEN=\"$REDIS_TOKEN\"" >> ~/.local/.local-infra-env
	log "Generated NATS and Redis tokens"
	
	if pacman -Q virtualbox-guest-utils &>/dev/null; then
		log "VirtualBox guest utilities detected, starting VBoxClient..."
		VBoxClient-all \
			|| warning "Failed to start VBoxClient-all"
	fi
	
	log "Additional configurations completed"
}

main() {
	log "=== Starting Arch Linux User Installation ==="
	log "Configuration:\n  git_email=$git_mail\n  install_leftwm=$INSTALL_LEFT"
	
	set_up_home_dir
	set_up_configuration_files
	install_aur_packages
	install_gui
	configure_ssh_and_git
	additional
	
	log "=== User installation completed successfully ==="
	log "Log file saved to: $LOG_FILE"
}

main


