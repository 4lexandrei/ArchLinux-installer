#!/bin/bash

source ./config.sh
source ./lib/gum.sh
source ./ArchLinux-installer/lib/gum.sh


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

display_cpu_info() {
    local cpu_info="No specific CPU detected"

    # Detect processor info
    cpu_info=$(lscpu | grep -E 'AuthenticAMD|GenuineIntel' | head -1)
    case "$cpu_info" in
        *AuthenticAMD*) echo "CPU: AMD" ;;
        *GenuineIntel*) echo "CPU: Intel" ;;
    esac
}

get_cpu_pkgs() {
    local cpu_info
    cpu_info=$(lscpu | grep -E 'AuthenticAMD|GenuineIntel' | head -1)

    case "$cpu_info" in
        *AuthenticAMD*) echo "amd-ucode" ;;
        *GenuineIntel*) echo "intel-ucode" ;;
        *) echo "" ;; # Return nothing if no match
    esac
}

display_gpu_info() {
    local gpu_info="No specific GPU detected"

    # Detect graphics card info
    gpu_info=$(lspci | grep -E 'AMD|Intel' | head -1)

    case "$gpu_info" in
        *AMD*) echo "GPU: AMD" ;;
        *Intel*) echo "GPU: Intel" ;;
    esac
}

get_gpu_pkgs() {
   local gpu_info
    gpu_info=$(lspci | grep -E 'AMD|Intel' | head -1)

    case "$gpu_info" in
        *AMD*) echo "mesa vulkan-radeon libva-mesa-driver" ;;
        *Intel*) echo "mesa vulkan-intel libva-intel-driver intel-media-driver" ;;
        *) echo "mesa" ;; # Default if no match
    esac
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

install_additional_packages() {
    clear
    local ADDITIONAL_PKGS=(
        base-devel
        nano
        sudo
        networkmanager
        # Bootloader
        grub
        # System drivers
        $(get_cpu_pkgs)
        $(get_gpu_pkgs)
        # Please add below for additional packages
    )

    # Check if gum is available inside chroot environment
    arch-chroot /mnt ./ArchLinux-installer/lib/gum.sh

    # Update system with pacman
    gum style "UPDATING SYSTEM"
    arch-chroot /mnt pacman -Syu --noconfirm

    # Install additional packages
    gum style "INSTALLING ADDITIONAL PACKAGES"
    arch-chroot /mnt pacman -S --noconfirm "${ADDITIONAL_PKGS[@]}"
}

configure_pacman
gum style "SYSTEM INFO"
display_cpu_info
display_gpu_info
install_base_system
generate_fstab
copy_pacman_conf

gum style "ENTERING CHROOT ENVIRONMENT"
sleep 3

if [[ "$INSTALL_ADDITIONAL_PACKAGES" = "true" ]]; then
    install_additional_packages
fi
