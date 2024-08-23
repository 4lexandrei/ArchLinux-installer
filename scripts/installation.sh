#!/bin/bash

source ./config.sh

# Configure pacman for faster installation
configure_pacman() {
    # Enable ParallelDownloads
    sed -i "s/^#ParallelDownloads/ParallelDownloads/" /etc/pacman.conf
    
    # Enable ILoveCandy 
    grep -qxF "ILoveCandy" /etc/pacman.conf || sed -i "/^ParallelDownloads/a ILoveCandy" /etc/pacman.conf
    
    # Enable multilib
    sed -i "/\[multilib\]/,/Include/ s/^#//" /etc/pacman.conf
}

display_cpu_info() {
    local cpu_info="No specific CPU detected"

    # Detect processor info
    cpu_info=$(lscpu | grep -E 'AuthenticAMD|GenuineIntel' | head -1)
    case "$cpu_info" in
        *AuthenticAMD*) echo "Detected AMD CPU" ;;
        *GenuineIntel*) echo "Detected Intel CPU" ;;
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

get_gpu_pkgs() {
   local gpu_info
    gpu_info=$(lspci | grep -E 'AMD|Intel' | head -1)
    
    case "$gpu_info" in
        *AMD*) echo "mesa vulkan-radeon libva-mesa-driver" ;;
        *Intel*) echo "mesa vulkan-intel libva-intel-driver intel-media-driver" ;;
        *) echo "mesa" ;; # Default if no match
    esac
}

display_gpu_info() {
    local gpu_info="No specific GPU detected"

    # Detect graphics card info
    gpu_info=$(lspci | grep -E 'AMD|Intel' | head -1)
    
    case "$gpu_info" in
        *AMD*) echo "Detected AMD GPU" ;;
        *Intel*) echo "Detected Intel GPU" ;;
    esac
}

install_packages() {
    local BASE_PKGS=(
        base linux linux-firmware
    )

    local ADDITIONAL_PKGS=(
        base-devel
        nano
        sudo
        networkmanager
        # Bootloader
        grub
        efibootmgr
        # System drivers
        $(get_cpu_pkgs)
        $(get_gpu_pkgs)
        # Please add below for additional packages
    )

    local PACKAGES=("${BASE_PKGS[@]}" "${ADDITIONAL_PKGS[@]}")

    echo -ne "
    -----------------------------------
       Installing essential packages
    -----------------------------------
    "

    pacstrap -K /mnt "${PACKAGES[@]}"
}

generate_fstab() {
    # Generate fstab
    echo "Generating fstab..."
    genfstab -U /mnt >> /mnt/etc/fstab

    echo "Displaying fstab..."
    cat /mnt/etc/fstab
}

configure_pacman
display_cpu_info
display_gpu_info
install_packages
generate_fstab