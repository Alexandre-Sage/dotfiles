#!/bin/bash
if ! REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null); then
    echo "Error: Not in a git repository"
    exit 1
fi

source "$REPO_ROOT/scripts/helpers/log.sh"

DISK_SIZE="50G"
ISO_FILE=""
DISK_FILE=""
RAM="1G"
CPUS="1"
HOST_SSH_PORT=""

# Parse arguments with getopt
TEMP=$(getopt -o "m:c:i:n:s:p:" \
    --long memory:,cpus:,iso:,name:,disk-size:,host-ssh-port: \
    -n 'install-vm.sh' -- "$@")

# Check if getopt failed
if [ $? != 0 ]; then 
    echo "Failed parsing options." >&2
    exit 1
fi

# Reorder arguments
eval set -- "$TEMP"

HOST_SSH_PORT=8022
# Process arguments
while true; do
    case "$1" in
        -m|--memory)
            RAM="$2"
            shift 2
            ;;
        -c|--cpus)
            CPUS="$2"
            shift 2
            ;;
        -i|--iso)
            ISO_FILE="$2"
            shift 2
            ;;
	-n|--name)
	    NAME="$2"
	    DISK_FILE="$2.qcow2"
	    shift 2
	    ;;
	-s|--disk-size)
	    DISK_SIZE="$2"
	    shift 2
	    ;;
	-p|--host-ssh-port)
	    HOST_SSH_PORT="$2"
	    ;;
        --)
            shift
            break
            ;;
        *)
            echo "Internal error!"
            exit 1
            ;;
    esac
done

# Validate required parameters

INSTALLED_VM_DIR="$REPO_ROOT/installed-vm/$NAME"

before_install_checks() {
	if [[ -z "$NAME" ]]; then
	    echo "Error: --name is required"
	    exit 1
	fi
	
	if [[ -z "$ISO_FILE" ]]; then
	    echo "Error: --iso is required"
	    exit 1
	fi
	if [ ! -f "$ISO_FILE" ]; then
	    echo "Error: ISO file not found at $ISO_FILE"
	    echo "Please download an OS ISO or provide a valid ISO file path with --iso"
	    exit 1
	fi
}


generate_start_command() {
    RAM="$RAM" \
    CPUS="$CPUS" \
    HOST_SSH_PORT="$HOST_SSH_PORT" \
    HARD_DRIVE="$INSTALLED_VM_DIR/$DISK_FILE" \
        envsubst < "$REPO_ROOT/scripts/vm/gui-virtual-machine.template" > "$INSTALLED_VM_DIR/start.sh"

    chmod +x "$INSTALLED_VM_DIR/start.sh"

}

create_vm_files() {
	if [ -d "$INSTALLED_VM_DIR" ]; then
	    warning "VM $NAME already exist"
	    read -p "This will boot from ISO. Continue? (y/n): " confirm
	    if [ "$confirm" != "y" ]; then
	        error "Installation cancelled."
	    else 
	    	log "Using existing disk: $DISK_FILE"
	    fi
        else
	    mkdir -p "$INSTALLED_VM_DIR"
	    log "Creating new virtual disk ($DISK_SIZE)..."
	    qemu-img create -f qcow2 "$INSTALLED_VM_DIR/$DISK_FILE" "$DISK_SIZE"
	    generate_start_command
	fi
}

install_command() {
	qemu-system-x86_64 \
	    -m "$RAM" \
	    -smp "$CPUS" \
	    -cpu qemu64 \
	    -enable-kvm \
	    -machine type=pc,accel=kvm \
	    -drive file="$INSTALLED_VM_DIR/$DISK_FILE",format=qcow2,if=virtio \
	    -cdrom "$ISO_FILE" \
	    -boot d \
	    -device virtio-net,netdev=network0 \
	    -vga virtio \
	    -display gtk
}

main() {
	log "Starting VM with ISO for OS installation..."
	log "Connect via VNC or use the display window to complete installation"
	log ""
	log "After installation:"
	log "  1. Shut down the VM"
	log "  2. Run $INSTALLED_VM_DIR/start.sh to start the VM normally"
	log ""

	before_install_checks
	create_vm_files
	install_command
}

main



