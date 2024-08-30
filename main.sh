#!/bin/bash

display_banner() {
    BANNER_PATH="./banner.sh"

    if [ -f "$BANNER_PATH" ]; then
        source "$BANNER_PATH"
    else
        echo "Banner not found: $BANNER_PATH"
    fi
}

# Make scripts executable
change_mode() {
    echo -e "Changing files permission to executable..."
    chmod +x ./scripts/prompts.sh
    chmod +x ./scripts/partition.sh
    chmod +x ./scripts/installation.sh
    chmod +x ./scripts/bootloader.sh
    chmod +x ./scripts/zram.sh
    chmod +x ./scripts/sys-config.sh
    echo -e "Files permissions updated successfully."
    sleep 3
}

copy_to_root() {    
    echo "Copying files to root..."

    mkdir -p /mnt/ArchLinux-installer
    cp -r /root/ArchLinux-installer/* /mnt/ArchLinux-installer

    echo "Files copied successfully."
}

clear

display_banner

change_mode

# Run prompt.sh
./scripts/prompts.sh

# Source the configuration file
source ./config.sh

# Run other scripts
./scripts/partition.sh
./scripts/installation.sh

# Copy ArchLinux-installer to root
copy_to_root

# Chroot to /mnt
arch-chroot /mnt ./ArchLinux-installer/scripts/bootloader.sh
arch-chroot /mnt ./ArchLinux-installer/scripts/zram.sh
arch-chroot /mnt ./ArchLinux-installer/scripts/sys-config.sh 
