#!/bin/bash

source ./lib/gum.sh

retry=true

partition_prompt() {
    lsblk
    echo ""
    read -rp "Please select your disk (e.g. sda): " DISK_ID
    clear
}

installation_prompts() {
    # Choose linux kernel
    # Choose if with drivers or without

    kernel_prompt() {
        local kernels=(
            linux               # Stable
            linux-lts           # Long Term Support
            linux-zen           # Zen
            linux-hardened      # Hardened
        )
        LINUX_KERNEL=$(gum choose --header "Please select linux kernel:" "${kernels[@]}")
    }

    additional_packages_prompt() {
        local prompt="Would you like to install additional packages? (GPU drivers)"
        response=$(gum choose --header "$prompt" "Yes (recommended)" "No")

        if [[ "$response" == "Yes" ]]; then
            INSTALL_ADDITIONAL_PACKAGES="true"
        else
            INSTALL_ADDITIONAL_PACKAGES="false"
        fi
    }

    kernel_prompt
    additional_packages_prompt
}

sys_config_prompts() {
    timezone_prompt() {
        clear
        local timezones=($(timedatectl list-timezones))
        TIMEZONE=$(gum choose --header "Please select your timezone:" "${timezones[@]}")
    }

    locale_prompt() {
        clear
        local locales=($(ls /usr/share/i18n/locales))
        LOCALE=$(gum choose --header "Please select your locale:" "${locales[@]}")
    }

    keyboard_prompt() {
        clear
        local layouts=($(localectl list-keymaps))
        LAYOUT=$(gum choose --header "Please select you keyboard layout:" "${layouts[@]}")
    }

    mirrors_prompt() {
        local countries=($(reflector --list-countries | awk 'NR > 2 {print $1}' | uniq))
        MIRRORS=$(gum choose --no-limit --header "Please select 1 or more mirrors:" "${countries[@]}" | tr '\n' ',')
    }

    hostname_prompt() {
        read -rp "Enter hostname: " HOSTNAME
    }

    timezone_prompt
    locale_prompt
    keyboard_prompt
    mirrors_prompt
    hostname_prompt
}

display_user_inputs() {
    echo "You entered the following:"
    echo "Disk: $DISK_ID"
    echo "Linux-kernel: $LINUX_KERNEL"
    echo "Install additional packages: $INSTALL_ADDITIONAL_PACKAGES"
    echo "Timezone: $TIMEZONE"
    echo "Locale: $LOCALE"
    echo "Keyboard: $LAYOUT"
    echo "Hostname: $HOSTNAME"
    echo "Mirrors: $MIRRORS"
}

while $retry; do
    clear
    partition_prompt
    installation_prompts
    sys_config_prompts

    #Show the user inputs
    clear
    display_user_inputs

    # Confirm information
    while true; do
        read -rp "Is this information correct? (y/n): " confirm
        case "$confirm" in
            [Yy] | [Yy][Ee][Ss])
                echo "Information confirmed. Proceeding..."
                retry=false
                break
                ;;
            [Nn] | [Nn][Oo])
                echo "Please try again"
                retry=true
                break
                ;;
            *)
                echo "Please enter 'yes' or 'no'."
                ;;
        esac
    done
done

# Save variables to a config file
cat <<EOF > config.sh
DISK_ID="$DISK_ID"
LINUX_KERNEL="$LINUX_KERNEL"
INSTALL_ADDITIONAL_PACKAGES="$INSTALL_ADDITIONAL_PACKAGES"
TIMEZONE="$TIMEZONE"
LOCALE="$LOCALE"
KEYBOARD="$LAYOUT"
HOSTNAME="$HOSTNAME"
MIRRORS="$MIRRORS"
EOF
