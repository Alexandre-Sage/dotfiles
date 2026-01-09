#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Get the dotfiles root directory (parent of gui/)
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$DOTFILES_ROOT/helpers/log.sh"

install_hyprland_packages() {
	log "Checking Hyprland packages..."
	
	local packages_to_install=()
	
	# Read packages from file and check each one
	while IFS= read -r package; do
		# Skip empty lines and comments
		[[ -z "$package" || "$package" =~ ^[[:space:]]*# ]] && continue
		
		if ! yay -Q "$package" &>/dev/null; then
			packages_to_install+=("$package")
		else
			log "$package already installed, skipping"
		fi
	done < "$SCRIPT_DIR/hyprland/packages"
	
	# Install only missing packages
	if [ ${#packages_to_install[@]} -gt 0 ]; then
		log "Installing packages: ${packages_to_install[*]}"
		yay -S "${packages_to_install[@]}" --noconfirm \
			|| error "Failed to install Hyprland packages"
	else
		log "All Hyprland packages are already installed"
	fi
}

configure_hyprland() {
	log "Configuring Hyprland..."
	
	if [ -e "$HOME/.config/hypr/hyprland.conf" ]; then
		warning "Hyprland config already exists, skipping"
	else
		mkdir -p "$HOME/.config/hypr" \
			|| error "Failed to create Hyprland config directory"
		
		ln -s "$SCRIPT_DIR/hyprland/hyprland.conf" "$HOME/.config/hypr/hyprland.conf" \
			|| error "Failed to create Hyprland config symlink"
		log "Hyprland config symlink created"
	fi
	
	log "Hyprland configuration completed"
}

main() {
	log "=== Starting Hyprland Installation ==="
	
	install_hyprland_packages
	configure_hyprland
	
	log "=== Hyprland installation completed successfully ==="
}

main
