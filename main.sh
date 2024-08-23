#!/bin/bash

clear

# Make scripts executable
chmod +x ./scripts/prompts.sh
chmod +x ./scripts/partition.sh
chmod +x ./scripts/installation.sh
chmod +x ./scripts/bootloader.sh
chmod +x ./scripts/sys-config.sh

LOGO_PATH="./logo.txt"

if [ -f "$LOGO_PATH" ]; then
    source "$LOGO_PATH"
else
    echo "Logo not found: $LOGO_PATH"
fi

# Run prompt.sh
./scripts/prompts.sh

# Source the configuration file
source ./config.sh

# Run other scripts
./scripts/partition.sh
./scripts/installation.sh

# Copy ArchLinux-installer to root
echo "Copying files to root..."

mkdir -p /mnt/ArchLinux-installer
cp -r /root/ArchLinux-installer/* /mnt/ArchLinux-installer

echo "Files copied successfully."

# Chroot to /mnt
arch-chroot /mnt ./ArchLinux-installer/scripts/bootloader.sh
arch-chroot /mnt ./ArchLinux-installer/scripts/sys-config.sh
