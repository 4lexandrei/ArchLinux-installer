#!/bin/bash

retry=true

partition_prompts() {
    lsblk
    read -rp "Please select your disk (e.g. sda): " DISK_ID
}

sys_config_prompts() {
    read -rp "Enter timezone (e.g. Region/City): " TIMEZONE
    read -rp "Enter locale (e.g. en_US): " LOCALE
    read -rp "Enter keyboard layout (e.g. us): " KEYBOARD
    read -rp "Enter hostname: " HOSTNAME
    
}

display_user_inputs() {
    echo "You entered the following:"
    echo "Disk: $DISK_ID"
    echo "Timezone: $TIMEZONE"
    echo "Locale: $LOCALE"
    echo "Keyboard: $KEYBOARD"
    echo "Hostname: $HOSTNAME"
}

while $retry; do
    partition_prompts

    sys_config_prompts

    #Show the user inputs
    display_user_inputs

    read -rp "Is this information correct? (y/n): " confirm
    if [ "$confirm" = "y" ]; then
        retry=false
    fi
done

# Save variables to a config file
cat <<EOF > config.sh
DISK_ID="$DISK_ID"
TIMEZONE="$TIMEZONE"
LOCALE="$LOCALE"
KEYBOARD="$KEYBOARD"
HOSTNAME="$HOSTNAME"
EOF
