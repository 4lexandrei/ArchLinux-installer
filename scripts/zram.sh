    #!/bin/bash

    source ./ArchLinux-installer/lib/gum.sh

    gum style "ZRAM CONFIGURATION"
    echo "Configuring zram..."
    echo "Installing zram-generator..."
    pacman -S --noconfirm --needed zram-generator

    ZRAM_CONFIG_FILE="/etc/systemd/zram-generator.conf"
    echo "Creating zram configuration file..."

    {
        echo "[zram0]"
        echo "zram-size = ram / 2"
        echo "compression-algorithm = zstd"
    } | tee $ZRAM_CONFIG_FILE

    echo "zram configuration file created."

    # Doesn't work inside chroot
    # systemctl daemon-reload
    # systemctl start systemd-zram-setup@zram0.service

    echo "zram configuration completed."
    echo "Note: zram swap will be available after reboot."
}

configure_zram
sleep 3
