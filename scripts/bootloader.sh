#!/bin/bash
source ./ArchLinux-installer/config.sh
source ./ArchLinux-installer/lib/gum.sh

clear

gum style "BOOTLOADER CONFIGURATION"

echo "Configuring bootloader..."

# Grub installation
if [ -d /sys/firmware/efi ]; then
    echo "Installing grub and efibootmgr..."
    pacman -S --noconfirm efibootmgr grub
    echo "Installing GRUB bootloader for UEFI..."
    grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB --recheck
else
    echo "Installing grub..."
    pacman -S --noconfirm grub
    echo "Installing GRUB bootloader for BIOS..."
    grub-install --target=i386-pc --recheck "/dev/$DISK_ID"
fi

# Generate configuration files
grub-mkconfig -o /boot/grub/grub.cfg

echo "Bootloader configuration complete."
