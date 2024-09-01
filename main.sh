#!/bin/bash

source ./lib/gum.sh

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
    chmod +x ./scripts/packages.sh
    chmod +x ./scripts/bootloader.sh
    chmod +x ./scripts/zram.sh
    chmod +x ./scripts/sys-config.sh
    echo -e "Files permissions updated successfully."
    sleep 3
}

copy_to_root() {
    echo "Copying ArchLinux-installer files to root..."

    mkdir -p /mnt/ArchLinux-installer
    cp -r /root/ArchLinux-installer/* /mnt/ArchLinux-installer

    echo "Files copied successfully."
}

clear

display_banner

timedatectl set-ntp true

# Update archlinux-keyring
echo "Updating archlinux-keyring..."
pacman --noconfirm -Sy archlinux-keyring

check_gum

change_mode

# Run prompt.sh
./scripts/prompts.sh

# Source configuration file
source ./config.sh

./scripts/partition.sh

# Copy ArchLinux-installer to root
copy_to_root

./scripts/installation.sh

# Chroot to /mnt
arch-chroot /mnt ./ArchLinux-installer/scripts/packages.sh
arch-chroot /mnt ./ArchLinux-installer/scripts/bootloader.sh
arch-chroot /mnt ./ArchLinux-installer/scripts/zram.sh
arch-chroot /mnt ./ArchLinux-installer/scripts/sys-config.sh
