#!/bin/bash

source ./config.sh
source ./lib/gum.sh

# Configure pacman for faster installation
configure_pacman() {
    gum style "PACMAN CONFIGURATION"
    echo "Configuring pacman..."
    # Enable ParallelDownloads
    sed -i "s/^#ParallelDownloads/ParallelDownloads/" /etc/pacman.conf

    # Enable ILoveCandy
    grep -qxF "ILoveCandy" /etc/pacman.conf || sed -i "/^ParallelDownloads/a ILoveCandy" /etc/pacman.conf

    # Enable multilib
    sed -i "/\[multilib\]/,/Include/ s/^#//" /etc/pacman.conf

    # Optimize mirrors with reflector
    optimize_mirrors() {
        echo "Backing up current mirrorlist..."

        if [ ! -f /etc/pacman.d/mirrorlist.bak ]; then
            cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
            echo "Mirrorlist backup created."
        else
            echo "Mirrorlist backup already exists."
        fi

        echo "Updating mirrors with reflector..."
        reflector --verbose -a 48 -c "$MIRRORS" -l 20 -f 10 -p https --sort rate --save /etc/pacman.d/mirrorlist
        echo "Mirrors optimized."
    }
    optimize_mirrors
    echo "Pacman configuration completed."
}

install_base_system() {
    local BASE_PKGS=(
        base
        $LINUX_KERNEL
        linux-firmware
    )

    gum style "ARCH LINUX INSTALLATION"

    pacstrap -K /mnt "${BASE_PKGS[@]}"
}

generate_fstab() {
    # Generate fstab
    echo "Generating fstab..."
    genfstab -U /mnt >> /mnt/etc/fstab

    echo "Displaying fstab..."
    gum style "FSTAB"
    cat /mnt/etc/fstab
    sleep 3
}

copy_pacman_conf() {
    echo "Copying pacman configurations to /mnt..."
    cp /etc/pacman.conf /mnt/etc/pacman.conf
    cp /etc/pacman.d/mirrorlist.bak /mnt/etc/pacman.d/mirrorlist.bak
    cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
    echo "Pacman configured."
}

configure_pacman
install_base_system
generate_fstab
copy_pacman_conf

gum style "ENTERING CHROOT ENVIRONMENT"
sleep 3
