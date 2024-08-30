#!/bin/bash

configure_zram() {
    echo "Configuring zram..."
    echo "Installing zram-generator..."
    pacman -S --noconfirm zram-generator

    ZRAM_CONFIG_FILE="/etc/systemd/zram-generator.conf"
    echo "Creating zram configuration file..."
    
    {
        echo "[zram0]"
        echo "zram-size = ram / 2"
        echo "compression-algorithm = zstd"
    } | tee zram.conf 

    echo "zram configuration file created."

    
    systemctl daemon-reload

    systemctl start systemd-zram-setup@zram0.service

    echo "Finished zram configuration."
}

configure_zram