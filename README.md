# ArchLinux-installer
Another automated installation bash script for Arch Linux.

## How to use
### Preparation
Before running the script, prepare your system with the following commands:
```bash
loadkeys <layout> 
pacman -Sy archlinux-keyring
pacman -Sy git
```
Clone the repository and run script
```bash
git clone https://github.com/4lexandrei/ArchLinux-installer.git
cd ArchLinux-installer/
./main.sh
```
### After reboot (Optional)
Set x11 keymap
```bash
localectl --no-convert set-x11-keymap <layout>
```
## More informations
### Features:
- **GPT Partitioning**: Supports UEFI or BIOS.
- **Drivers**: Supports Intel, AMD or Nvidia.
- **Zram swap**: Configures zram for efficient swapping.
- **SSD Maintenance**: Enables periodic TRIM.

### Script Breakdown:
1) Preset partition
2) Install packages
3) GRUB Bootloader setup
4) Set up zram swap 
5) System configuration

### Unsupported features:
- Manual partitioning
- Set X11 keymap

### Dependencies
- gum