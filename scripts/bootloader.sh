#!/bin/bash

# Grub installation
echo "Installing GRUB bootloader..."
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB

# Generate configuration files
grub-mkconfig -o /boot/grub/grub.cfg

echo "Bootloader configuration complete."