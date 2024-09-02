#!/bin/bash

source ./ArchLinux-installer/lib/gum.sh
source ./ArchLinux-installer/config.sh

get_cpu_packages() {
    local cpu_info="No specific CPU detected."
    cpu_packages=()

    cpu_info=$(lscpu | grep -iE 'AuthenticAMD|GenuineIntel' | head -1)

    case "$cpu_info" in
        *AuthenticAMD*)
            cpu_packages+=("amd-ucode") ;;
        *GenuineIntel*)
            cpu_packages+=("intel-ucode") ;;
        *)
            ;;
    esac

    echo "CPU packages: ${cpu_packages[@]}"
}


get_gpu_packages() {
   local gpu_info="No specific GPU detected."
   gpu_packages=()

    gpu_info=$(lspci | grep -iE 'VGA|3D' | head -1)

    case "$gpu_info" in
        *NVIDIA*)
            gpu_packages+=("nvidia") ;;
        *AMD*|*Radeon*)
            gpu_packages+=("mesa" "vulkan-radeon" "libva-mesa-driver") ;;
        *Intel*)
            gpu_packages+=("mesa" "vulkan-intel" "libva-intel-driver" "intel-media-driver") ;;
        *)
            gpu_packages+=("mesa") ;;
    esac

    echo "GPU packages: ${gpu_packages[@]}"
}

install_essential_packages() {
    get_cpu_packages

    local ESSENTIAL_PKGS=(
        base-devel
        nano
        sudo
        networkmanager
        # Microcode
        "${cpu_packages[@]}"
    )

    # Install essential packages
    gum style "INSTALLING ESSENTIAL PACKAGES"
    echo "${ESSENTIAL_PKGS[@]}"
    pacman -S --noconfirm --needed "${ESSENTIAL_PKGS[@]}"
}

install_additional_packages() {
    get_gpu_packages

    local ADDITIONAL_PKGS=(
        "${gpu_packages[@]}"
    )

    # Install additional packages
    gum style "INSTALLING ADDITIONAL PACKAGES"
    echo "${ADDITIONAL_PKGS[@]}"
    pacman -S --noconfirm --needed "${ADDITIONAL_PKGS[@]}"
}

# Check if gum is available inside chroot environment
check_gum
sleep 3
clear

gum style "CHROOT ENVIRONMENT"

# Update system with pacman
gum style "UPDATING SYSTEM"
pacman -Syu --noconfirm

install_essential_packages

if [[ "$INSTALL_ADDITIONAL_PACKAGES" = "true" ]]; then
    install_additional_packages
fi
