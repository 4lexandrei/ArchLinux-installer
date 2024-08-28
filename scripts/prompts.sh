#!/bin/bash

source ./lib/advance_menu.sh

retry=true

partition_prompts() {
    lsblk
    read -rp "Please select your disk (e.g. sda): " DISK_ID
}

sys_config_prompts() {
    configure_timezone() {
        local timezones=($(timedatectl list-timezones))
        single_select_menu "Please select your timezone:" "${timezones[@]}"
        TIMEZONE=$(echo "$SELECTED_OPTION")
    }

    configure_locale() {
        local locales=($(ls /usr/share/i18n/locales))
        single_select_menu "Please select your locale:" "${locales[@]}"
        LOCALE=$(echo "$SELECTED_OPTION") 
    }

    configure_keyboard() {
        local layouts=($(localectl list-keymaps))
        single_select_menu "Please select you keyboard layout:" "${layouts[@]}"
        LAYOUT=$(echo "$SELECTED_OPTION")
    }
    
    configure_mirrors() {
        local countries=($(reflector --list-countries | awk 'NR > 2 {print $1}' | uniq))
        multi_select_menu "Please select 1 or more mirrors:" "${countries[@]}"
        MIRRORS=$(echo "$SELECTED_OPTIONS" | tr ' ' ',')
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
