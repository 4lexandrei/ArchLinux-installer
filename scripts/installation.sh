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

    # Optimize mirrors with reflector
    optimize_mirrors() {
        echo "Backing up current mirrorlist..."
        cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
        echo "Updating mirrors with reflector..."
        reflector --verbose -a 48 -c "$MIRRORS" -l 20 -f 10 -p https --sort rate --save /etc/pacman.d/mirrorlist
        echo "Mirrors optimized."
    }
    optimize_mirrors
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

install_base_system() {
    local BASE_PKGS=(
        base 
        linux 
        linux-firmware
    )

    echo -e "                                      "
    echo -e "--------------------------------------"
    echo -e "        Installing base system        "
    echo -e "--------------------------------------"
    echo -e "                                      "

    pacstrap -K /mnt "${BASE_PKGS[@]}"
}

generate_fstab() {
    # Generate fstab
    echo "Generating fstab..."
    genfstab -U /mnt >> /mnt/etc/fstab

    echo "Displaying fstab..."
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

    # Enter chroot environment
    echo -e "                                     "
    echo -e "-------------------------------------"
    echo -e "           Updating system           "
    echo -e "-------------------------------------"
    echo -e "                                     "

    arch-chroot /mnt pacman -Syu --noconfirm

    echo -e "                                      "
    echo -e "--------------------------------------"
    echo -e "    Installing additional packages    "
    echo -e "--------------------------------------"
    echo -e "                                      "

    arch-chroot /mnt pacman -S --noconfirm "${ADDITIONAL_PKGS[@]}"
}

configure_pacman
display_cpu_info
display_gpu_info
install_base_system
generate_fstab
copy_pacman_conf

echo -e "Entering chroot environment..."

install_additional_packages