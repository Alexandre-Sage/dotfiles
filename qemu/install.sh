#!/usr/bin/env bash
set -euo pipefail  

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

source "$SCRIPTPATH/scripts/helpers/log.sh"
source "$SCRIPTPATH/scripts/helpers/utils.sh"

create_architecture() {
	log "Create quemu working dir architecture"

	if [[ ! -d $SCRIPTPATH/iso ]]; then
		log "Creating the iso file at $SCRIPTPATH/iso" 
		mkdir "$SCRIPTPATH/iso"
	else
		log "Iso folder already exist"
	fi

	if [[ ! -d $SCRIPTPATH/installed-vm ]]; then
		log "Creating the iso file at $SCRIPTPATH/installed-vm" 
		mkdir "$SCRIPTPATH/installed-vm"
	else
		log "Installed folder already exist"
	fi
}

install_qemu_full() {
	pacman -S qemu-full --noconfirm
}


main() {
	check_privileges
	install_qemu_full
	create_architecture
}

