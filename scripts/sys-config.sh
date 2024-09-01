#!/bin/bash

source ./ArchLinux-installer/config.sh
source ./ArchLinux-installer/lib/gum.sh

clear

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
    display_accounts() {
        local title="SYSTEM ACCOUNTS"
        local seperator="─────────────────────────────────"
        local accounts=(
            root
            user:"$USERNAME"
        )

        local join=$(gum join --align center --vertical "$title" "$seperator" "${accounts[@]}")
        gum style --border normal "$join"
    }

    clear

    echo "Configuring system accounts..."

    sys_accounts_prompts

    display_accounts

    # Set root password
    echo "root:$ROOT_PASSWORD" | chpasswd

    #Create the user and set password
    useradd -m -G wheel -s /bin/bash "$USERNAME"
    echo "$USERNAME:$USER_PASSWORD" | chpasswd

    #uncomment WHEEL group
    sed -i "/^# %wheel ALL=(ALL:ALL) ALL/s/^# //" /etc/sudoers

    echo "Done."
}

gum style "CONFIGURING SYSTEM"

# Enable services
systemctl enable NetworkManager
systemctl enable fstrim.timer   # Enables Periodic TRIM

# Set Time
ln -sf /usr/share/zoneinfo/"$TIMEZONE" /etc/localtime
hwclock --systohc

# Set locale
sed -i "/^# *$LOCALE.UTF-8/s/^# *//" /etc/locale.gen
locale-gen
echo "LANG=$LOCALE.UTF-8" > /etc/locale.conf

# Set keyboard layout
echo "KEYMAP=$KEYBOARD" > /etc/vconsole.conf
# Need to find a solution for setting up x11 keymap

# Set hostname
echo "$HOSTNAME" > /etc/hostname

sleep 3

sys_accounts

gum style "SYSTEM CONFIGURATION COMPLETED"

echo -e ""

gum style "Please use the command 'umount -R /mnt' and 'reboot' the system"
