#!/bin/bash

source ./lib/gum.sh

retry=true

partition_prompts() {
    lsblk
    read -rp "Please select your disk (e.g. sda): " DISK_ID
}

sys_config_prompts() {
    configure_timezone() {
        clear
        local timezones=($(timedatectl list-timezones))
        TIMEZONE=$(gum choose --header "Please select your timezone:" "${timezones[@]}")
    }

    configure_locale() {
        clear
        local locales=($(ls /usr/share/i18n/locales))
        LOCALE=$(gum choose --header "Please select your locale:" "${locales[@]}")
    }

    configure_keyboard() {
        clear
        local layouts=($(localectl list-keymaps))
        LAYOUT=$(gum choose --header "Please select you keyboard layout:" "${layouts[@]}")
    }
    
    configure_mirrors() {
        local countries=($(reflector --list-countries | awk 'NR > 2 {print $1}' | uniq))
        MIRRORS=$(gum choose --no-limit --header "Please select 1 or more mirrors:" "${countries[@]}" | tr '\n' ',') 
    }

    configure_timezone
    configure_locale
    configure_keyboard
    configure_mirrors
    read -rp "Enter hostname: " HOSTNAME
}

display_user_inputs() {
    echo "You entered the following:"
    echo "Disk: $DISK_ID"
    echo "Timezone: $TIMEZONE"
    echo "Locale: $LOCALE"
    echo "Keyboard: $LAYOUT"
    echo "Hostname: $HOSTNAME"
    echo "Mirrors: $MIRRORS"
}

while $retry; do
    clear
    partition_prompts
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
TIMEZONE="$TIMEZONE"
LOCALE="$LOCALE"
KEYBOARD="$LAYOUT"
HOSTNAME="$HOSTNAME"
MIRRORS="$MIRRORS"
EOF
