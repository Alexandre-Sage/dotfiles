#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Get the dotfiles root directory (parent of gui/)
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$DOTFILES_ROOT/helpers/log.sh"

install_leftwm_package() {
	log "Checking LeftWM packages..."
	
	local packages_to_install=()
	
	# Check each package and add to install list if not present
	if ! yay -Q leftwm &>/dev/null; then
		packages_to_install+=("leftwm")
	else
		log "leftwm already installed, skipping"
	fi
	
	if ! yay -Q leftwm-config &>/dev/null; then
		packages_to_install+=("leftwm-config")
	else
		log "leftwm-config already installed, skipping"
	fi
	
	if ! yay -Q leftwm-theme-git &>/dev/null; then
		packages_to_install+=("leftwm-theme-git")
	else
		log "leftwm-theme-git already installed, skipping"
	fi
	
	if ! yay -Q lemonbar-xft-git &>/dev/null; then
		packages_to_install+=("lemonbar-xft-git")
	else
		log "lemonbar-xft-git already installed, skipping"
	fi
	
	# Install only missing packages
	if [ ${#packages_to_install[@]} -gt 0 ]; then
		log "Installing packages: ${packages_to_install[*]}"
		yay -S "${packages_to_install[@]}" --noconfirm \
			|| error "Failed to install LeftWM packages"
	else
		log "All LeftWM packages are already installed"
	fi
}

configure_leftwm() {
	log "Configuring LeftWM..."
	
	if [ -e "$HOME/.config/leftwm" ]; then
		warning "LeftWM config symlink already exists, removing it"
		rm -rf $HOME/.config/leftwm
	fi

	ln -s $SCRIPT_DIR/leftwm $HOME/.config/leftwm \
		|| error "Failed to create LeftWM config symlink"
	log "LeftWM config symlink created"
	
	log "Applying LeftWM theme 'perso'..."
	leftwm-theme apply "perso" \
		|| warning "Failed to apply LeftWM theme"
	
	log "LeftWM configuration completed"
}

main() {
	log "=== Starting LeftWM Installation ==="
	
	install_leftwm_package
	configure_leftwm
	
	log "=== LeftWM installation completed successfully ==="
}

main
