# ArchLinux-installer
Another ArchLinux install script

## How to use
Preparation
```
loadkeys layout
pacman -Sy archlinux-keyring
pacman -Sy git
```
Clone repo and run script
```
git clone https://github.com/4lexandrei/ArchLinux-installer.git
cd ArchLinux-installer/
./main.sh
```

## More informations
Supports:
- GPT: UEFI & BIOS
- Intel & AMD drivers

Warning!
Currently doesn't support:
- Nvidia GPU drivers.

Script breakdown:
1) Preset partition
2) Install packages
3) GRUB Bootloader setup
4) System configuration

Planning to add:
- Manual partitioning
- Support to zram
- Better bash UI
