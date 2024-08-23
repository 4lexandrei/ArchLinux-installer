#!/bin/bash
source ./config.sh

DISK="/dev/$DISK_ID"

# Partitions
EFI_PART=""
SWAP_PART=""
ROOT_PART=""
HOME_PART=""

umount_all() {
    # Turn off swap partitions
    echo "Turning off swap partitions..."
    for swap in $(swapon --show=NAME --noheadings); do
        echo "Swapping off $swap"
        swapoff "$swap"
    done

    # Unmount partitions
    echo "Unmounting all partitions under /mnt..."
    if mountpoint -q /mnt; then
        umount -R /mnt
    fi
}

preset_partition() {
    umount_all

    BIOS_SIZE="5"
    EFI_SIZE="1024"
    SWAP_SIZE="4096"
    ROOT_SIZE="53248"
    START_POINT="1"

    create_partition() {
        local PART_TYPE=$1
        local PART_SIZE=$2

        local END_POINT=$((START_POINT + PART_SIZE))

        parted --script "$DISK" mkpart '""' "$PART_TYPE" ${START_POINT}MiB ${END_POINT}MiB
    
        START_POINT=$END_POINT
    }

    echo "Partitioning with preset configuration..."

    echo "Creating GPT parition table on $DISK"
    parted --script "$DISK" mklabel gpt

    if [ -d /sys/firmware/efi ]; then
        echo "UEFI supported, creating EFI partition..."
        create_partition "fat32" $EFI_SIZE
        parted --script "$DISK" set 1 esp on
        EFI_PART="${DISK}1"
    else
        echo "UEFI not supported, creating BIOS boot partition..."
        create_partition "bios_grub" $BIOS_SIZE
        BIOS_PART="${DISK}1"
    fi

    create_partition "linux-swap" $SWAP_SIZE
    SWAP_PART="${DISK}2"

    create_partition "ext4" $ROOT_SIZE
    ROOT_PART="${DISK}3"

    echo "Creating Home parititon with remaining space"
    parted --script "$DISK" mkpart '""' ext4 ${START_POINT}MiB 100%
    HOME_PART="${DISK}4"

    format_and_mount
}

format_and_mount() {
    echo "Formatting partitions..."

    if [ -n "$EFI_PART" ]; then
        mkfs.fat -F 32 "$EFI_PART"
    elif [ -n "$BIOS_PART" ]; then
        echo "BIOS boot partition created, no formatting needed."
    fi

    [ -n "$SWAP_PART" ] && { mkswap "$SWAP_PART"; swapon "$SWAP_PART"; }
    [ -n "$ROOT_PART" ] && mkfs.ext4 "$ROOT_PART"
    [ -n "$HOME_PART" ] && mkfs.ext4 "$HOME_PART"

    echo "Formatting complete."

    echo "Mounting partitions..."

    [ -n "$ROOT_PART" ] && { mount "$ROOT_PART" /mnt; echo "Root mounted."; }
    [ -n "$EFI_PART" ] && { mount --mkdir "$EFI_PART" /mnt/efi; echo "EFI mounted."; }
    [ -n "$HOME_PART" ] && { mount --mkdir "$HOME_PART" /mnt/home; echo "Home mounted."; }

    echo "Mounting complete."
}


preset_partition