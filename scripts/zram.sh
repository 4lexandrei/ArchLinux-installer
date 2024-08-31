    #!/bin/bash

    source ./ArchLinux-installer/lib/gum.sh

    gum style "ZRAM CONFIGURATION"
    echo "Configuring zram..."
    echo "Installing zram-generator..."
    pacman -S --noconfirm zram-generator

    ZRAM_CONFIG_FILE="/etc/systemd/zram-generator.conf"
    echo "Creating zram configuration file..."

    {
        echo "[zram0]"
        echo "zram-size = ram / 2"
        echo "compression-algorithm = zstd"
    } | tee $ZRAM_CONFIG_FILE

    echo "zram configuration file created."


    systemctl daemon-reload # Doesn't work inside chroot

    systemctl start systemd-zram-setup@zram0.service # Doesn't word inside chroot

    echo "zram configuration completed." 
}

configure_zram
