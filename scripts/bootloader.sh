#!/bin/bash

source ./ArchLinux-installer/config.sh

# Grub installation
echo "Installing GRUB bootloader..."

if [ -d /sys/firmware/efi ]; then
    grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB --recheck
else
    grub-install --target=i386-pc --recheck "/dev/$DISK_ID"
fi

# Generate configuration files
grub-mkconfig -o /boot/grub/grub.cfg

echo "Bootloader configuration complete."