#!/bin/bash

clear

source ./ArchLinux-installer/config.sh

# Configure pacman for faster installation
configure_pacman() {
    # Enable ParallelDownloads
    sed -i "s/^#ParallelDownloads/ParallelDownloads/" /etc/pacman.conf
    
    # Enable ILoveCandy 
    grep -qxF "ILoveCandy" /etc/pacman.conf || sed -i "/^ParallelDownloads/a ILoveCandy" /etc/pacman.conf
    
    # Enable multilib
    sed -i "/\[multilib\]/,/Include/ s/^#//" /etc/pacman.conf
}
configure_pacman

set_root_password() {
    while true; do
        read -rsp "Enter root password: " ROOT_PASSWORD
        echo
        read -rsp "Confirm root password: " ROOT_PASSWORD_CONFIRM
        echo

        if [[ "$ROOT_PASSWORD" == "$ROOT_PASSWORD_CONFIRM" ]]; then
            echo "Root password set successfully."
            return 0
        else
            echo "Error: Passwords do not match. Please try again."
        fi
    done
}

set_user_password() {
    while true; do
        read -rsp "Enter user password: " USER_PASSWORD
        echo
        read -rsp "Confirm user password: " USER_PASSWORD_CONFIRM
        echo

        if [[ "$USER_PASSWORD" == "$USER_PASSWORD_CONFIRM" ]]; then
            echo "User password set successfully."
            return 0
        else
            echo "Error: Passwords do not match. Please try again."
        fi
    done
}

sys_accounts_prompts() {
    set_root_password
    read -rp "Enter username: " USERNAME
    set_user_password
}


# System accounts
sys_accounts() {
    clear
    echo "Configuring system accounts..."

    sys_accounts_prompts

    echo -e "                               "
    echo -e " ++=========================++ "
    echo -e " ||     SYSTEM ACCOUNTS     || "
    echo -e " ++=========================++ "
    echo -e "    root                       "
    echo -e "    User: $USERNAME            "
    echo -e " +===========================+ "
    echo -e "                               "
    # Set root password
    echo "root:$ROOT_PASSWORD" | chpasswd

    #Create the user and set password
    useradd -m -G wheel -s /bin/bash "$USERNAME"
    echo "$USERNAME:$USER_PASSWORD" | chpasswd

    #uncomment WHEEL group
    sed -i "/^# %wheel ALL=(ALL:ALL) ALL/s/^# //" /etc/sudoers

    echo "Done."
}

echo "Configuring system..."

# Enable services
systemctl enable NetworkManager --now

# Set Time
ln -sf /usr/share/zoneinfo/"$TIMEZONE" /etc/localtime
hwclock --systohc
f
# Set locale
sed -i "/^# *$LOCALE.UTF-8/s/^# *//" /etc/locale.gen
locale-gen
echo "LANG=$LOCALE.UTF-8" > /etc/locale.conf

# Set keyboard layout
localectl --no-convert set-keymap "$KEYBOARD"
localectl --no-convert set-x11-keymap "$KEYBOARD"

# Set hostname
echo "$HOSTNAME" > /etc/hostname

sleep 3 

sys_accounts

echo "System configuration completed."

echo -e ""
echo -ne "Please use "umount -a" command and reboot the system."